import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Country.name) private var countries: [Country]
    @State private var searchText = ""
    @State private var showingAddCountry = false
    @State private var countryToDelete: Country? = nil
    @State private var showingDeleteCountry = false
    @AppStorage("lastCityID") private var lastCityIDString: String = ""
    @State private var showingQuickAdd = false
    @State private var showingSavedToast = false
    @State private var savedCityName = ""
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showingProfile = false
    @State private var showingTrips = false

    struct CityMatch: Identifiable {
        let id = UUID()
        let city: City
        let country: Country
    }

    struct EntryMatch: Identifiable {
        let id = UUID()
        let entry: PlaceEntry
        let city: City
        let country: Country
    }

    var matchingCities: [CityMatch] {
        guard !searchText.isEmpty else { return [] }
        return countries.flatMap { country in
            country.cities
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                .map { CityMatch(city: $0, country: country) }
        }
    }

    var matchingEntries: [EntryMatch] {
        guard !searchText.isEmpty else { return [] }
        return countries.flatMap { country in
            country.cities.flatMap { city in
                city.entries
                    .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                    .map { EntryMatch(entry: $0, city: city, country: country) }
            }
        }
    }

    var filteredCountries: [Country] {
        if searchText.isEmpty { return countries }
        return countries.filter { country in
            country.name.localizedCaseInsensitiveContains(searchText) ||
            country.cities.contains { city in
                city.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var lastCity: City? {
        guard let uuid = UUID(uuidString: lastCityIDString) else { return nil }
        let allCities = (try? modelContext.fetch(FetchDescriptor<City>())) ?? []
        return allCities.first { $0.id == uuid }
    }

    var totalCountries: Int { countries.count }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {

                ZStack {
                    AppTheme.Colour.homeBackground
                        .ignoresSafeArea()

                    VStack(spacing: 0) {

                        VStack(spacing: 6) {
                            Text("SafarNama")
                                .font(AppTheme.Font.displayLarge)
                                .foregroundStyle(AppTheme.Colour.inkDark)
                            Text("your travel diary")
                                .font(AppTheme.Font.handwritingMedium)
                                .foregroundStyle(AppTheme.Colour.inkLight)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppTheme.Spacing.md)
                        .padding(.bottom, AppTheme.Spacing.md)

                        HStack {
                            StampStatView(count: totalCountries, label: "countries")
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.bottom, AppTheme.Spacing.md)

                        if filteredCountries.isEmpty {
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Spacer()
                                Text("no places yet")
                                    .font(AppTheme.Font.handwritingLarge)
                                    .foregroundStyle(AppTheme.Colour.inkLight)
                                Text("tap + to add your first country")
                                    .font(AppTheme.Font.handwritingSmall)
                                    .foregroundStyle(AppTheme.Colour.inkLight.opacity(0.7))
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            List {
                                if !matchingCities.isEmpty {
                                    Section("Cities") {
                                        ForEach(matchingCities) { match in
                                            NavigationLink(destination: CityView(city: match.city)) {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(match.city.name)
                                                            .font(AppTheme.Font.displaySmall)
                                                        Text(match.country.name)
                                                            .font(AppTheme.Font.handwritingSmall)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                }
                                            }
                                            .listRowBackground(AppTheme.Colour.homeBackground)
                                            .listRowSeparator(.hidden)
                                        }
                                    }
                                }

                                if !matchingEntries.isEmpty {
                                    Section("Entries") {
                                        ForEach(matchingEntries) { match in
                                            NavigationLink(destination: EntryDetailView(entry: match.entry)) {
                                                HStack {
                                                    Image(systemName: match.entry.category.icon)
                                                        .foregroundStyle(match.entry.category.color)
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(match.entry.name)
                                                            .font(AppTheme.Font.displaySmall)
                                                        Text("\(match.city.name), \(match.country.name)")
                                                            .font(AppTheme.Font.handwritingSmall)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                }
                                            }
                                            .listRowBackground(AppTheme.Colour.homeBackground)
                                            .listRowSeparator(.hidden)
                                        }
                                    }
                                }

                                ForEach(filteredCountries) { country in
                                    ZStack {
                                        NavigationLink(destination: CityListView(country: country)) {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                        CountryCardView(country: country)
                                    }
                                    .listRowBackground(AppTheme.Colour.homeBackground)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(
                                        top: AppTheme.Spacing.xs,
                                        leading: AppTheme.Spacing.md,
                                        bottom: AppTheme.Spacing.xs,
                                        trailing: AppTheme.Spacing.md
                                    ))
                                }
                                .onDelete { offsets in
                                    if let index = offsets.first {
                                        countryToDelete = filteredCountries[index]
                                        showingDeleteCountry = true
                                    }
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                }

                    // Floating quick add button
                    Button {
                        showingQuickAdd = true
                    } label: {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppTheme.Colour.homeBackground)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.Colour.inkDark.opacity(0.85))
                            .clipShape(Circle())
                            .shadow(color: AppTheme.Colour.inkDark.opacity(0.3), radius: 12, x: 0, y: 6)
                            .overlay {
                                Circle()
                                    .strokeBorder(AppTheme.Colour.inkLight.opacity(0.2), lineWidth: 1)
                            }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 40)

                    // Toast
                    if showingSavedToast {
                        VStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.Colour.stampGreen)
                                Text("Saved to \(savedCityName)")
                                    .font(AppTheme.Font.handwritingMedium)
                                    .foregroundStyle(AppTheme.Colour.inkDark)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(AppTheme.Colour.surface)
                            .cornerRadius(AppTheme.Radius.lg)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .padding(.bottom, 110)
                        }
                        .frame(maxWidth: .infinity)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(), value: showingSavedToast)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, prompt: "search countries, cities, entries...")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddCountry = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                Image(systemName: "plus")
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.Colour.inkDark)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingProfile = true
                        } label: {
                            Image(systemName: "person.circle")
                                .foregroundStyle(AppTheme.Colour.inkDark)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingTrips = true
                        } label: {
                            Image(systemName: "suitcase.rolling")
                                .foregroundStyle(AppTheme.Colour.inkDark)
                        }
                    }
                }
                .sheet(isPresented: $showingAddCountry) {
                    AddCountryView()
                }
                .sheet(isPresented: $showingProfile) {
                    ProfileView(authViewModel: authViewModel)
                }
                .sheet(isPresented: $showingTrips) {
                    TripsListView()
                }
                .sheet(isPresented: $showingQuickAdd) {
                    QuickAddView(initialCity: lastCity) { cityName in
                        savedCityName = cityName
                        showingSavedToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            showingSavedToast = false
                        }
                    }
                }
                .alert("Delete \(countryToDelete?.name ?? "country")?", isPresented: $showingDeleteCountry) {
                    Button("Delete", role: .destructive) {
                        if let country = countryToDelete {
                            modelContext.delete(country)
                            SyncService.autoPushIfLoggedIn(modelContext: modelContext)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will delete all cities and entries inside it. This cannot be undone.")
                }
            }
        }
    }
