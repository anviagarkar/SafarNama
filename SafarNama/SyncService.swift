import Foundation
import SwiftData
import Combine

enum SyncError: Error {
    case notLoggedIn
    case networkError
    case serverError
}

// Lightweight, self-contained sync status any view can observe without
// needing to be wired up to whatever calls autoPushIfLoggedIn(). Add
// `@StateObject private var syncStatus = SyncStatus.shared` (or
// `@ObservedObject`) in a view to show a banner/toast when isSyncing is
// true or lastError is non-nil.
@MainActor
final class SyncStatus: ObservableObject {
    static let shared = SyncStatus()
    private init() {}

    @Published var isSyncing: Bool = false
    @Published var lastError: Error?
    @Published var lastSuccessfulSyncAt: Date?

    // Stashed so NetworkMonitor can retry a push as soon as connectivity
    // returns, without needing its own route to a ModelContext. Set every
    // time autoPushIfLoggedIn runs, so it's always the most recent context
    // in use.
    var pendingModelContext: ModelContext?
}

class SyncService {
    static let baseURL = APIConfig.baseURL

    // Custom encoder/decoder so Date fields survive the Swift <-> Java round trip.
    //
    // Swift's default JSONEncoder date strategy encodes a Date as a raw Double
    // (seconds since 2001), which Java's Instant can't parse at all, so we force
    // ISO-8601 on the way out.
    //
    // On the way in, Java's Instant.toString() sometimes includes fractional
    // seconds (e.g. "2026-03-01T10:15:30.123Z") and sometimes doesn't
    // (e.g. "2026-03-01T10:15:30Z") depending on whether the instant happens to
    // land exactly on a whole second. A single ISO8601DateFormatter can only
    // handle one of those shapes, so we try the fractional-seconds formatter
    // first and fall back to the plain one.
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let whole = ISO8601DateFormatter()
        whole.formatOptions = [.withInternetDateTime]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = fractional.date(from: string) ?? whole.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO-8601 date: \(string)"
            )
        }
        return decoder
    }()

    // MARK: - Push

    static func push(modelContext: ModelContext) async throws {
        guard let token = KeychainHelper.read(forKey: "jwt") else {
            throw SyncError.notLoggedIn
        }

        let countries = (try? modelContext.fetch(FetchDescriptor<Country>())) ?? []

        let countryDTOs = countries.map { country in
            CountryDTO(
                name: country.name,
                isHome: country.isHome,
                colorHex: country.colorHex,
                cities: country.cities.map { city in
                    CityDTO(
                        name: city.name,
                        entries: city.entries.filter { $0.customTab == nil }.map(entryToDTO),
                        customTabs: city.customTabs.map { tab in
                            TabDTO(
                                name: tab.name,
                                emoji: tab.emoji,
                                entries: tab.entries.map(entryToDTO)
                            )
                        }
                    )
                }
            )
        }

        let trips = (try? modelContext.fetch(FetchDescriptor<Trip>())) ?? []
        let tripDTOs = trips.map { TripDTO(name: $0.name, startDate: $0.startDate, endDate: $0.endDate) }

        let payload = SyncPayload(countries: countryDTOs, trips: tripDTOs)

        guard let url = URL(string: "\(baseURL)/sync/push") else {
            throw SyncError.networkError
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 150
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try jsonEncoder.encode(payload)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SyncError.serverError
        }
    }

    private static func entryToDTO(_ entry: PlaceEntry) -> EntryDTO {
        EntryDTO(
            name: entry.name,
            category: entry.category.rawValue,
            notes: entry.notes,
            rating: entry.rating,
            cuisine: entry.cuisine?.rawValue,
            foodType: entry.foodType?.rawValue,
            locationName: entry.locationName,
            locationAddress: entry.locationAddress,
            latitude: entry.latitude,
            longitude: entry.longitude,
            isWishlist: entry.isWishlist,
            date: entry.date,
            tripName: entry.trip?.name
        )
    }

    // MARK: - Pull

    static func pull(modelContext: ModelContext) async throws {
        guard let token = KeychainHelper.read(forKey: "jwt") else {
            throw SyncError.notLoggedIn
        }

        // Push first if we have local data, same as before — protects against
        // pulling and wiping out local changes that never made it to the server.
        //
        // This now throws instead of swallowing the error: if the safety push
        // fails (no network, server down), we abort the pull entirely rather
        // than proceeding to overwrite local data with a possibly-stale server
        // copy. Losing a sync is recoverable; silently losing local edits isn't.
        let localCountries = (try? modelContext.fetch(FetchDescriptor<Country>())) ?? []
        if !localCountries.isEmpty {
            try await push(modelContext: modelContext)
        }

        guard let url = URL(string: "\(baseURL)/sync/pull") else {
            throw SyncError.networkError
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 150
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SyncError.serverError
        }

        let pullResponse = try jsonDecoder.decode(SyncPullResponse.self, from: data)

        // Wipe-and-rebuild, same pattern as before, now also for trips.
        let existingCountries = (try? modelContext.fetch(FetchDescriptor<Country>())) ?? []
        for country in existingCountries {
            modelContext.delete(country)
        }
        let existingTrips = (try? modelContext.fetch(FetchDescriptor<Trip>())) ?? []
        for trip in existingTrips {
            modelContext.delete(trip)
        }

        // Build trips first so entries below can be linked to them by name.
        var tripsByName: [String: Trip] = [:]
        for tripResponse in pullResponse.trips {
            let trip = Trip(name: tripResponse.name, startDate: tripResponse.startDate, endDate: tripResponse.endDate)
            modelContext.insert(trip)
            tripsByName[trip.name] = trip
        }

        for countryResponse in pullResponse.countries {
            let country = Country(
                name: countryResponse.name,
                isHome: countryResponse.isHome,
                colorHex: countryResponse.colorHex
            )
            modelContext.insert(country)

            for cityResponse in countryResponse.cities {
                let city = City(name: cityResponse.name, country: country)
                modelContext.insert(city)
                country.cities.append(city)

                for entryResponse in cityResponse.entries {
                    let entry = dtoToEntry(entryResponse, city: city, tripsByName: tripsByName)
                    modelContext.insert(entry)
                    city.entries.append(entry)
                }

                for tabResponse in cityResponse.customTabs {
                    let tab = CustomTab(name: tabResponse.name, emoji: tabResponse.emoji, city: city)
                    modelContext.insert(tab)
                    city.customTabs.append(tab)

                    for entryResponse in tabResponse.entries {
                        let entry = dtoToEntry(entryResponse, city: city, tripsByName: tripsByName)
                        entry.customTab = tab
                        modelContext.insert(entry)
                        city.entries.append(entry)
                    }
                }
            }
        }

        // This now throws instead of swallowing the error. By this point the
        // old local data has already been deleted and the new data inserted
        // in-memory — if save() fails here, that's the one real "lose
        // everything" scenario in this file, so the caller needs to know.
        try modelContext.save()
    }

    private static func dtoToEntry(_ dto: EntryResponse, city: City, tripsByName: [String: Trip]) -> PlaceEntry {
        let entry = PlaceEntry(
            name: dto.name,
            category: Category(rawValue: dto.category) ?? .place,
            notes: dto.notes,
            rating: dto.rating,
            cuisine: dto.cuisine.flatMap { Cuisine(rawValue: $0) },
            foodType: dto.foodType.flatMap { FoodType(rawValue: $0) },
            date: dto.date,
            city: city,
            locationName: dto.locationName,
            locationAddress: dto.locationAddress,
            latitude: dto.latitude,
            longitude: dto.longitude
        )
        // Both of these were previously missing after a pull — wishlist items
        // would un-wishlist themselves, and entries would all get "now" as
        // their date. Fixed here, same function, same root cause.
        entry.isWishlist = dto.isWishlist
        entry.trip = dto.tripName.flatMap { tripsByName[$0] }
        return entry
    }

    // MARK: - Auto push

    static func autoPushIfLoggedIn(modelContext: ModelContext) {
        guard KeychainHelper.read(forKey: "jwt") != nil else { return }
        Task {
            await MainActor.run {
                SyncStatus.shared.isSyncing = true
                SyncStatus.shared.pendingModelContext = modelContext
            }
            do {
                try await push(modelContext: modelContext)
                await MainActor.run {
                    SyncStatus.shared.isSyncing = false
                    SyncStatus.shared.lastError = nil
                    SyncStatus.shared.lastSuccessfulSyncAt = Date()
                }
            } catch {
                await MainActor.run {
                    SyncStatus.shared.isSyncing = false
                    SyncStatus.shared.lastError = error
                }
            }
        }
    }
}
