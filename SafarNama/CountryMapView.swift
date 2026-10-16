import SwiftUI
import MapKit

struct CountryMapView: View {
    let country: Country

    private let mapNavyColour = Color(hex: "1A2E5A")

    var allEntriesWithLocation: [PlaceEntry] {
        country.cities.flatMap { $0.entries }
            .filter { $0.latitude != nil && $0.longitude != nil }
    }

    var orderedRoute: [PlaceEntry] {
        nearestNeighbourOrder(allEntriesWithLocation)
    }

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedEntry: PlaceEntry? = nil

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {

                // Route line — safe, no force unwraps
                if orderedRoute.count > 1 {
                    MapPolyline(coordinates: orderedRoute.compactMap { entry in
                        guard let lat = entry.latitude,
                              let lon = entry.longitude else { return nil }
                        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    })
                    .stroke(
                        mapNavyColour,
                        style: StrokeStyle(lineWidth: 2.5, dash: [6, 4])
                    )
                }

                // Pins — safe, no force unwraps
                ForEach(allEntriesWithLocation) { entry in
                    if let lat = entry.latitude, let lon = entry.longitude {
                        Annotation(
                            entry.name,
                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        ) {
                            Button {
                                selectedEntry = entry
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(mapNavyColour)
                                        .frame(width: 30, height: 30)
                                    Image(systemName: entry.category.icon)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 13))
                                }
                                .shadow(radius: 2)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard)

            // Empty state
            if allEntriesWithLocation.isEmpty {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "map")
                        .font(.system(size: 40))
                        .foregroundStyle(country.accentColor.opacity(0.4))
                    Text("no pinned places yet")
                        .font(AppTheme.Font.handwritingLarge)
                        .foregroundStyle(country.inkColour)
                    Text("add a location to an entry to see it here")
                        .font(AppTheme.Font.handwritingSmall)
                        .foregroundStyle(country.inkColour.opacity(0.6))
                }
                .padding()
                .background(country.backgroundColour.opacity(0.9))
                .cornerRadius(AppTheme.Radius.lg)
            }
        }
        .navigationTitle("\(country.name) map")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedEntry) { entry in
            NavigationStack {
                EntryDetailView(entry: entry)
            }
        }
        .overlay(alignment: .top) {
            if !allEntriesWithLocation.isEmpty
                && allEntriesWithLocation.count < totalEntryCount {
                Text("\(allEntriesWithLocation.count) of \(totalEntryCount) places have a location")
                    .font(AppTheme.Font.handwritingSmall)
                    .foregroundStyle(country.inkColour)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(country.backgroundColour.opacity(0.95))
                    .cornerRadius(AppTheme.Radius.md)
                    .padding(.top, 8)
            }
        }
    }

    var totalEntryCount: Int {
        country.cities.flatMap { $0.entries }.count
    }

    // MARK: - Nearest neighbour route ordering

    private func nearestNeighbourOrder(_ entries: [PlaceEntry]) -> [PlaceEntry] {
        guard !entries.isEmpty else { return [] }
        var remaining = entries
        var route: [PlaceEntry] = [remaining.removeFirst()]

        while !remaining.isEmpty {
            guard let last = route.last,
                  let lastLat = last.latitude,
                  let lastLon = last.longitude else { break }

            let lastLocation = CLLocation(latitude: lastLat, longitude: lastLon)

            let nearestIndex = remaining.indices.min(by: { a, b in
                let latA = remaining[a].latitude ?? 0
                let lonA = remaining[a].longitude ?? 0
                let latB = remaining[b].latitude ?? 0
                let lonB = remaining[b].longitude ?? 0
                let locA = CLLocation(latitude: latA, longitude: lonA)
                let locB = CLLocation(latitude: latB, longitude: lonB)
                return lastLocation.distance(from: locA) < lastLocation.distance(from: locB)
            })

            guard let index = nearestIndex else { break }
            route.append(remaining.remove(at: index))
        }

        return route
    }
}
