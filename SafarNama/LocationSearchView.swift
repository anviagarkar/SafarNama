//
//  LocationSearchView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 12/04/2026.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct LocationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var results: [MKMapItem] = []
    @State private var isSearching = false
    @StateObject private var locationManager = CurrentLocationManager()
    @State private var searchTask: Task<Void, Never>? = nil

    var onSelect: (LocationResult) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppTheme.Colour.inkLight)
                    TextField("Search for a place...", text: $searchText)
                        .font(AppTheme.Font.handwritingMedium)
                        .foregroundStyle(AppTheme.Colour.inkDark)
                        .onChange(of: searchText) { _, newValue in
                            searchTask?.cancel()
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 300_000_000)
                                guard !Task.isCancelled else { return }
                                await MainActor.run { search(query: newValue) }
                            }
                        }
                    if isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            results = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppTheme.Colour.inkLight)
                        }
                    }
                }
                .padding(AppTheme.Spacing.sm)
                .background(AppTheme.Colour.surface)
                .cornerRadius(AppTheme.Radius.md)
                .padding(AppTheme.Spacing.md)

                // Use current location
                Button {
                    locationManager.requestLocation(explicit: true)
                } label: {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(AppTheme.Colour.stampBlue)
                        Text("Use current location")
                            .font(AppTheme.Font.handwritingMedium)
                            .foregroundStyle(AppTheme.Colour.stampBlue)
                        Spacer()
                        if locationManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                }
                .buttonStyle(.plain)

                Divider()
                    .overlay(AppTheme.Colour.inkLight.opacity(0.2))

                if results.isEmpty && !searchText.isEmpty && !isSearching {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Spacer()
                        Text("no results found")
                            .font(AppTheme.Font.handwritingLarge)
                            .foregroundStyle(AppTheme.Colour.inkLight)
                        Spacer()
                    }
                } else {
                    List(results, id: \.self) { item in
                        Button {
                            let coord = item.placemark.coordinate
                            let address = buildAddress(from: item)
                            let result = LocationResult(
                                name: item.name ?? "",
                                address: address,
                                latitude: coord.latitude,
                                longitude: coord.longitude
                            )
                            onSelect(result)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name ?? "Unknown")
                                    .font(AppTheme.Font.displaySmall)
                                    .foregroundStyle(AppTheme.Colour.inkDark)
                                let address = buildAddress(from: item)
                                if !address.isEmpty {
                                    Text(address)
                                        .font(AppTheme.Font.handwritingSmall)
                                        .foregroundStyle(AppTheme.Colour.inkLight)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(AppTheme.Colour.surface)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppTheme.Colour.background)
            .navigationTitle("Add location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: locationManager.currentMapItem) { _, newItem in
                if let item = newItem, locationManager.isExplicitRequest {
                    let coord = item.placemark.coordinate
                    let result = LocationResult(
                        name: item.name ?? "",
                        address: item.placemark.locality ?? "",
                        latitude: coord.latitude,
                        longitude: coord.longitude
                    )
                    onSelect(result)
                    dismiss()
                }
            }
            .onAppear {
                if locationManager.currentMapItem == nil {
                        locationManager.requestLocation()
                    }
            }
        }
    }

    private func search(query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.pointOfInterest, .address]
        if let userLocation = locationManager.currentMapItem?.placemark.coordinate {
            request.region = MKCoordinateRegion(
                center: userLocation,
                latitudinalMeters: 50000,
                longitudinalMeters: 50000
            )
        }
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            isSearching = false
            results = response?.mapItems ?? []
        }
    }

    private func buildAddress(from item: MKMapItem) -> String {
        [
            item.placemark.subThoroughfare,
            item.placemark.thoroughfare,
            item.placemark.locality,
            item.placemark.country
        ].compactMap { $0 }.joined(separator: ", ")
    }
}

// MARK: - Current location manager

class CurrentLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var isLoading = false
    @Published var currentMapItem: MKMapItem? = nil
    var isExplicitRequest = false

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation(explicit: Bool = false) {
        isExplicitRequest = explicit
        isLoading = true
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            isLoading = false
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            self.isLoading = false
            if let placemark = placemarks?.first {
                let mkPlacemark = MKPlacemark(coordinate: location.coordinate)
                let mapItem = MKMapItem(placemark: mkPlacemark)
                mapItem.name = placemark.name ?? placemark.locality
                self.currentMapItem = mapItem
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
    }
}
