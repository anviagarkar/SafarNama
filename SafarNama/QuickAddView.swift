//
//  QuickAddView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 01/05/2026.
//

import SwiftUI
import SwiftData
import MapKit

struct QuickAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Country.name) private var countries: [Country]
    @Query(sort: \Trip.name) private var trips: [Trip]

    @State private var selectedCountry: Country?
    @State private var selectedCity: City?
    @State private var name = ""
    @State private var category: Category = .food
    @State private var locationName: String? = nil
    @State private var locationAddress: String? = nil
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    @State private var showingLocationSearch = false
    @State private var isWishlist: Bool = false
    @State private var selectedTrip: Trip? = nil
    @State private var showingClearLocation = false
    @State private var showingAddCountry = false
    @State private var showingAddCity = false
    @State private var countryNamesBeforeAdd: Set<String> = []
    @State private var cityNamesBeforeAdd: Set<String> = []
    @FocusState private var focusedField: Field?

    enum Field {
        case name
    }

    let initialCity: City?
    let initialTrip: Trip?
    var onSave: (String) -> Void

    init(initialCity: City?, initialTrip: Trip? = nil, onSave: @escaping (String) -> Void = { _ in }) {
        self.initialCity = initialCity
        self.initialTrip = initialTrip
        self.onSave = onSave
    }

    var citiesForSelectedCountry: [City] {
        selectedCountry?.cities.sorted { $0.name < $1.name } ?? []
    }

    var canSave: Bool {
        !name.isEmpty && selectedCity != nil
    }

    var body: some View {
        NavigationStack {
            if countries.isEmpty {
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "globe")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.Colour.inkLight.opacity(0.4))
                    Text("Add a country first")
                        .font(AppTheme.Font.handwritingLarge)
                        .foregroundStyle(AppTheme.Colour.inkDark)
                    Text("Quick add needs at least one country to file entries under")
                        .font(AppTheme.Font.handwritingSmall)
                        .foregroundStyle(AppTheme.Colour.inkLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button {
                        showingAddCountry = true
                    } label: {
                        Text("Add a Country")
                            .font(AppTheme.Font.handwritingMedium)
                    }
                    .padding(.top, AppTheme.Spacing.sm)
                }
                .navigationTitle("Quick add")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .sheet(isPresented: $showingAddCountry) {
                    AddCountryView()
                }
            } else {
                Form {

                    Section("Where") {
                        Picker("Country", selection: $selectedCountry) {
                            Text("Select country").tag(Optional<Country>.none)
                            ForEach(countries) { country in
                                Text(country.name).tag(Optional(country))
                            }
                        }
                        .onChange(of: selectedCountry) { _, newCountry in
                            if selectedCity?.country?.id != newCountry?.id {
                                selectedCity = newCountry?.cities.first
                            }
                        }

                        Button {
                            countryNamesBeforeAdd = Set(countries.map { $0.name })
                            showingAddCountry = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle")
                                Text("Add New Country")
                            }
                            .font(AppTheme.Font.handwritingSmall)
                        }

                        if let country = selectedCountry {
                            if citiesForSelectedCountry.isEmpty {
                                Button {
                                    cityNamesBeforeAdd = Set(citiesForSelectedCountry.map { $0.name })
                                    showingAddCity = true
                                } label: {
                                    Text("Add a City to \(country.name)")
                                        .font(AppTheme.Font.handwritingMedium)
                                }
                            } else {
                                Picker("City", selection: $selectedCity) {
                                    Text("Select city").tag(Optional<City>.none)
                                    ForEach(citiesForSelectedCountry) { city in
                                        Text(city.name).tag(Optional(city))
                                    }
                                }
                            }
                        }
                    }

                    Section("Place") {
                        if let address = locationAddress {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(AppTheme.Colour.stampRed)
                                VStack(alignment: .leading, spacing: 2) {
                                    if let locName = locationName {
                                        Text(locName)
                                            .font(AppTheme.Font.handwritingMedium)
                                            .foregroundStyle(AppTheme.Colour.inkDark)
                                    }
                                    Text(address)
                                        .font(AppTheme.Font.handwritingSmall)
                                        .foregroundStyle(AppTheme.Colour.inkLight)
                                }
                                Spacer()
                                Button {
                                    showingClearLocation = true
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(AppTheme.Colour.inkLight)
                                }
                            }
                        } else {
                            Button {
                                showingLocationSearch = true
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundStyle(AppTheme.Colour.stampRed)
                                    Text("Search for a place")
                                        .font(AppTheme.Font.handwritingMedium)
                                        .foregroundStyle(AppTheme.Colour.stampRed)
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        TextField("Name", text: $name)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                    }

                    Section("Category") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                ForEach(Category.allCases, id: \.self) { cat in
                                    Button {
                                        category = cat
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 12))
                                            Text(cat.rawValue)
                                                .font(AppTheme.Font.handwritingSmall)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            category == cat
                                            ? AppTheme.Colour.inkDark
                                            : AppTheme.Colour.backgroundWarm
                                        )
                                        .foregroundStyle(
                                            category == cat
                                            ? AppTheme.Colour.surface
                                            : AppTheme.Colour.inkMedium
                                        )
                                        .cornerRadius(20)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Section("Trip") {
                        Picker("Trip", selection: $selectedTrip) {
                            Text("None").tag(Optional<Trip>.none)
                            ForEach(trips) { trip in
                                Text(trip.name).tag(Optional(trip))
                            }
                        }
                        if trips.isEmpty {
                            Text("Create a trip from the suitcase icon on Home to tag entries to it")
                                .font(AppTheme.Font.handwritingSmall)
                                .foregroundStyle(AppTheme.Colour.inkLight)
                        }
                    }

                    Section {
                        Toggle(isOn: $isWishlist) {
                            HStack(spacing: 8) {
                                Image(systemName: "bookmark.fill")
                                    .foregroundStyle(AppTheme.Colour.stampGreen)
                                Text("Add to Wishlist")
                                    .font(AppTheme.Font.handwritingMedium)
                            }
                        }
                        .tint(AppTheme.Colour.stampGreen)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle("Quick add")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { save() }
                            .disabled(!canSave)
                    }
                }
                .onAppear {
                    if let city = initialCity {
                        selectedCity = city
                        selectedCountry = city.country
                    } else {
                        selectedCountry = countries.first
                        selectedCity = countries.first?.cities.first
                    }
                    if let trip = initialTrip {
                        selectedTrip = trip
                    }
                }
                .sheet(isPresented: $showingLocationSearch) {
                    LocationSearchView { result in
                        if name.isEmpty { name = result.name }
                        locationName = result.name
                        locationAddress = result.address
                        latitude = result.latitude
                        longitude = result.longitude
                    }
                }
                .sheet(isPresented: $showingAddCity, onDismiss: {
                    if let country = selectedCountry,
                       let newCity = country.cities.first(where: { !cityNamesBeforeAdd.contains($0.name) }) {
                        selectedCity = newCity
                    }
                }) {
                    if let country = selectedCountry {
                        AddCityView(country: country)
                    }
                }
                .sheet(isPresented: $showingAddCountry, onDismiss: {
                    if let newCountry = countries.first(where: { !countryNamesBeforeAdd.contains($0.name) }) {
                        selectedCountry = newCountry
                        selectedCity = newCountry.cities.first
                    }
                }) {
                    AddCountryView()
                }
                .alert("Remove location?", isPresented: $showingClearLocation) {
                    Button("Remove", role: .destructive) {
                        locationName = nil
                        locationAddress = nil
                        latitude = nil
                        longitude = nil
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will remove the linked location from this entry.")
                }
            }
        }
    }

    private func save() {
        guard let city = selectedCity else { return }
        let entry = PlaceEntry(
            name: name,
            category: category,
            notes: "",
            rating: 0,
            cuisine: nil,
            foodType: category == .food ? .restaurant : nil,
            date: Date(),
            city: city,
            locationName: locationName,
            locationAddress: locationAddress,
            latitude: latitude,
            longitude: longitude
        )
        entry.isWishlist = isWishlist
        entry.trip = selectedTrip
        city.entries.append(entry)
        modelContext.insert(entry)
        onSave(city.name)
        dismiss()
    }
}
