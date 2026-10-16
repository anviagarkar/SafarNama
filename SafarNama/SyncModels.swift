import Foundation

struct SyncPayload: Codable {
    let countries: [CountryDTO]
    let trips: [TripDTO]
}

struct CountryDTO: Codable {
    let name: String
    let isHome: Bool
    let colorHex: String
    let cities: [CityDTO]
}

struct CityDTO: Codable {
    let name: String
    let entries: [EntryDTO]
    let customTabs: [TabDTO]
}

struct TabDTO: Codable {
    let name: String
    let emoji: String
    let entries: [EntryDTO]
}

struct EntryDTO: Codable {
    let name: String
    let category: String
    let notes: String
    let rating: Int
    let cuisine: String?
    let foodType: String?
    let locationName: String?
    let locationAddress: String?
    let latitude: Double?
    let longitude: Double?
    let isWishlist: Bool
    let date: Date
    let tripName: String?
}

struct TripDTO: Codable {
    let name: String
    let startDate: Date?
    let endDate: Date?
}

struct SyncPullResponse: Codable {
    let countries: [CountryResponse]
    let trips: [TripResponse]
}

struct CountryResponse: Codable {
    let id: Int
    let name: String
    let isHome: Bool
    let colorHex: String
    let cities: [CityResponse]

    enum CodingKeys: String, CodingKey {
            case id, name, colorHex, cities
            case isHome = "home"
    }
}

struct CityResponse: Codable {
    let id: Int
    let name: String
    let entries: [EntryResponse]
    let customTabs: [TabResponse]
}

struct TabResponse: Codable {
    let id: Int
    let name: String
    let emoji: String
    let entries: [EntryResponse]
}

struct EntryResponse: Codable {
    let id: Int
    let name: String
    let category: String
    let notes: String
    let rating: Int
    let cuisine: String?
    let foodType: String?
    let locationName: String?
    let locationAddress: String?
    let latitude: Double?
    let longitude: Double?
    let isWishlist: Bool
    let date: Date
    let tripName: String?

    enum CodingKeys: String, CodingKey {
        case id, name, category, notes, rating, cuisine, foodType, locationName, locationAddress, latitude, longitude
        case date, tripName
        case isWishlist = "wishlist"
    }
}

struct TripResponse: Codable {
    let id: Int
    let name: String
    let startDate: Date?
    let endDate: Date?
}
