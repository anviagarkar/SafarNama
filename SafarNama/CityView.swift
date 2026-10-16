import SwiftUI
import SwiftData

struct CityView: View {
    @Environment(\.modelContext) private var modelContext
    let city: City
    @State private var selectedTab: CityTab = .fixed(.food)
    @State private var showingAddEntry = false
    @State private var showingEditCity = false
    @State private var showingAddTab = false
    @State private var showingDeleteTab = false
    @State private var tabToDelete: CustomTab? = nil
    @State private var entryToDelete: PlaceEntry? = nil
    @State private var showingDeleteEntry = false
    @AppStorage("lastCityID") private var lastCityIDString: String = ""
    @State private var searchText = ""

    var isSearching: Bool { !searchText.isEmpty }

    var searchResults: [PlaceEntry] {
        city.entries.filter { entry in
            !entry.isWishlist &&
            (entry.name.localizedCaseInsensitiveContains(searchText) ||
             entry.notes.localizedCaseInsensitiveContains(searchText) ||
             (entry.locationName?.localizedCaseInsensitiveContains(searchText) ?? false))
        }
    }

    var accentColor: Color { city.accentColor }
    var bgColour: Color { city.bgColour }
    var inkColour: Color { city.inkColour }

    var allTabs: [CityTab] {
        let fixed = Category.allCases.map { CityTab.fixed($0) }
        let custom = city.customTabs.map { CityTab.custom($0) }
        return fixed + custom
    }
    
    var filteredEntries: [PlaceEntry] {
        switch selectedTab {
        case .fixed(let category):
            return city.entries.filter { $0.category == category && $0.customTab == nil && !$0.isWishlist }
        case .custom(let tab):
            return tab.entries.filter { !$0.isWishlist }
        }
    }

    private func foodGrouped(for foodType: FoodType) -> [PlaceEntry] {
        filteredEntries.filter { $0.foodType == foodType }
    }
    
    private var foodListView: some View {
        ForEach(FoodType.allCases, id: \.self) { foodType in
            let grouped = foodGrouped(for: foodType)
            if !grouped.isEmpty {
                Section {
                    ForEach(grouped) { entry in
                        NavigationLink(destination: EntryDetailView(entry: entry)) {
                            EntryRowView(entry: entry)
                        }
                        .listRowBackground(bgColour)
                        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                    }
                    .onDelete { offsets in
                        if let index = offsets.first {
                            entryToDelete = grouped[index]
                            showingDeleteEntry = true
                        }
                    }
                } header: {
                    foodSectionHeader(for: foodType)
                }
            }
        }
    }
    
    private func foodSectionHeader(for foodType: FoodType) -> some View {
        HStack(spacing: 6) {
            Image(systemName: foodType.icon)
                .font(.system(size: 12))
                .padding(6)
                .background(accentColor.opacity(0.15))
                .clipShape(Circle())
            Text(foodType.rawValue.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .kerning(1.2)
        }
        .foregroundStyle(accentColor)
        .textCase(nil)
        .padding(.vertical, 4)
    }
    
    var body: some View {
        ZStack {
            bgColour.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: — Cover hero
                if let data = city.coverPhoto, let uiImage = UIImage(data: data) {
                    GeometryReader { geo in
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height + geo.safeAreaInsets.top)
                                .clipped()
                                .offset(y: -geo.safeAreaInsets.top)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)

                        Text(city.name)
                            .font(AppTheme.Font.displayLarge)
                            .foregroundStyle(inkColour)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 6)
                } else {
                    Text(city.name)
                        .font(AppTheme.Font.displayLarge)
                        .foregroundStyle(inkColour)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                        .padding(.bottom, 8)
                }
                
                // Tab bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(allTabs, id: \.self) { tab in
                            Button {
                                selectedTab = tab
                                searchText = ""
                            } label: {
                                VStack(spacing: 4) {
                                    if tab.isEmoji {
                                        Text(tab.icon)
                                            .font(.system(size: 18))
                                    } else {
                                        Image(systemName: tab.icon)
                                    }
                                    Text(tab.title)
                                        .font(AppTheme.Font.handwritingSmall)
                                }
                                .frame(minWidth: 72)
                                .padding(.vertical, 10)
                                .foregroundStyle(
                                    selectedTab == tab
                                    ? accentColor
                                    : inkColour.opacity(0.5)
                                )
                                .overlay(alignment: .bottom) {
                                    if selectedTab == tab {
                                        Rectangle()
                                            .frame(height: 2)
                                            .foregroundStyle(accentColor)
                                    }
                                }
                            }
                            .contextMenu {
                                if case .custom(let customTab) = tab {
                                    Button(role: .destructive) {
                                        tabToDelete = customTab
                                        showingDeleteTab = true
                                    } label: {
                                        Label("Delete tab", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        
                        // Add tab button
                        Button {
                            showingAddTab = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("add")
                                    .font(AppTheme.Font.handwritingSmall)
                            }
                            .frame(minWidth: 52)
                            .padding(.vertical, 10)
                            .foregroundStyle(inkColour.opacity(0.35))
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.sm)
                }
                .background(bgColour.opacity(0.8))
                
                Divider()
                    .overlay(inkColour.opacity(0.15))
                
                // Entry list
                if isSearching {
                    if searchResults.isEmpty {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundStyle(accentColor.opacity(0.4))
                            Text("no matches")
                                .font(AppTheme.Font.handwritingLarge)
                                .foregroundStyle(inkColour)
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(searchResults) { entry in
                                NavigationLink(destination: EntryDetailView(entry: entry)) {
                                    EntryRowView(entry: entry)
                                }
                                .listRowBackground(bgColour)
                                .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                        .background(bgColour)
                    }
                    
                } else if filteredEntries.isEmpty {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Spacer()
                        if case .custom(let tab) = selectedTab {
                            Text(tab.emoji)
                                .font(.system(size: 40))
                        } else {
                            Image(systemName: selectedTab.icon)
                                .font(.system(size: 40))
                                .foregroundStyle(accentColor.opacity(0.4))
                        }
                        Text("no \(selectedTab.title.lowercased()) entries yet")
                            .font(AppTheme.Font.handwritingLarge)
                            .foregroundStyle(inkColour)
                        Text("tap + to add one")
                            .font(AppTheme.Font.handwritingSmall)
                            .foregroundStyle(inkColour.opacity(0.6))
                        Spacer()
                    }
                } else {
                    List {
                        if case .fixed(let category) = selectedTab, category == .food {
                            foodListView
                        } else {
                            ForEach(filteredEntries) { entry in
                                NavigationLink(destination: EntryDetailView(entry: entry)) {
                                    EntryRowView(entry: entry)
                                }
                                .listRowBackground(bgColour)
                                .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                            }
                            .onDelete { offsets in
                                if let index = offsets.first {
                                    entryToDelete = filteredEntries[index]
                                    showingDeleteEntry = true
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(bgColour)
                }
            }
        }
        .searchable(text: $searchText, prompt: "search entries...")
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    NavigationLink(destination: CityWishlistView(city: city)) {
                        Image(systemName: "bookmark")
                            .foregroundStyle(accentColor)
                    }
                    Button {
                        showingEditCity = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(accentColor)
                    }
                    Button {
                        showingAddEntry = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            if case .custom(let tab) = selectedTab {
                AddEditEntryView(city: city, initialCategory: .place, customTab: tab)
            } else if case .fixed(let category) = selectedTab {
                AddEditEntryView(city: city, initialCategory: category)
            }
        }
        .sheet(isPresented: $showingEditCity) {
            EditCityView(city: city)
        }
        .sheet(isPresented: $showingAddTab) {
            AddCustomTabView(city: city)
        }
        .alert("Delete \(entryToDelete?.name ?? "entry")?", isPresented: $showingDeleteEntry) {
            Button("Delete", role: .destructive) {
                if let entry = entryToDelete {
                    deleteEntryConfirmed(entry)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .alert("Delete \(tabToDelete?.name ?? "tab")?", isPresented: $showingDeleteTab) {
            Button("Delete", role: .destructive) {
                if let tab = tabToDelete {
                    deleteTabConfirmed(tab)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all entries in this tab. This cannot be undone.")
        }
        .onAppear {
            lastCityIDString = city.id.uuidString
        }
    }

    private func deleteEntryConfirmed(_ entry: PlaceEntry) {
        if let i = city.entries.firstIndex(where: { $0.id == entry.id }) {
            city.entries.remove(at: i)
        }
        modelContext.delete(entry)
        SyncService.autoPushIfLoggedIn(modelContext: modelContext)
        
    }

    private func deleteTabConfirmed(_ tab: CustomTab) {
        if case .custom(let currentTab) = selectedTab,
           currentTab.id == tab.id {
            selectedTab = .fixed(.food)
        }
        if let index = city.customTabs.firstIndex(where: { $0.id == tab.id }) {
            city.customTabs.remove(at: index)
        }
        modelContext.delete(tab)
        SyncService.autoPushIfLoggedIn(modelContext: modelContext)
    }
}
