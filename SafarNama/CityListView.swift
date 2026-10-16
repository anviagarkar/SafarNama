import SwiftUI
import SwiftData

struct CityListView: View {
    @Environment(\.modelContext) private var modelContext
    let country: Country
    @State private var showingAddCity = false
    @State private var showingEditCountry = false
    @State private var cityToDelete: City? = nil
    @State private var showingDeleteCity = false
    @State private var showingCountryMap = false
    @State private var searchText = ""

    var filteredCities: [City] {
        if searchText.isEmpty { return country.cities }
        return country.cities.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            country.backgroundColour
                .ignoresSafeArea()

            List {
                ForEach(filteredCities) { city in
                    NavigationLink(destination: CityView(city: city)) {
                        CityRowView(city: city, accentColor: country.accentColor, inkColour: country.inkColour)
                    }
                    .listRowBackground(country.backgroundColour)
                    .contextMenu {
                        Button(role: .destructive) {
                            cityToDelete = city
                            showingDeleteCity = true
                        } label: {
                            Label("Delete city", systemImage: "trash")
                        }
                    }
                }
                .onDelete { offsets in
                    if let index = offsets.first {
                        cityToDelete = country.cities[index]
                        showingDeleteCity = true
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(country.backgroundColour)
            .overlay {
                if country.cities.isEmpty {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "building.2")
                            .font(.system(size: 40))
                            .foregroundStyle(country.accentColor.opacity(0.4))
                        Text("no cities yet")
                            .font(AppTheme.Font.handwritingLarge)
                            .foregroundStyle(country.inkColour)
                        Text("tap + to add a city in \(country.name)")
                            .font(AppTheme.Font.handwritingSmall)
                            .foregroundStyle(country.inkColour.opacity(0.6))
                    }
                }
            }
        }
        .navigationTitle(country.name)
        .searchable(text: $searchText, prompt: "search cities...")
        .toolbarColorScheme(
            country.countryColour == .navy ||
            country.countryColour == .burgundy ||
            country.countryColour == .slateBlue ? .dark : .light,
            for: .navigationBar
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        showingEditCountry = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(country.accentColor)
                    }
                    Button {
                        showingAddCity = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(country.accentColor)
                    }
                    Button {
                        showingCountryMap = true
                    } label: {
                        Image(systemName: "map")
                            .foregroundStyle(country.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCity) {
            AddCityView(country: country)
        }
        .sheet(isPresented: $showingEditCountry) {
            AddCountryView(editingCountry: country)
        }
        .navigationDestination(isPresented: $showingCountryMap) {
            CountryMapView(country: country)
        }
        .alert("Delete \(cityToDelete?.name ?? "city")?", isPresented: $showingDeleteCity) {
            Button("Delete", role: .destructive) {
                if let city = cityToDelete {
                    modelContext.delete(city)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all entries inside it. This cannot be undone.")
        }
    }
}
