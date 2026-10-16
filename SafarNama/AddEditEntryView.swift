import SwiftUI
import SwiftData
import PhotosUI
import MapKit

struct AddEditEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Trip.name) private var trips: [Trip]

    let city: City?
    var editingEntry: PlaceEntry? = nil
    var initialCategory: Category = .food
    var customTab: CustomTab? = nil

    @State private var name = ""
    @State private var selectedTab: CityTab = .fixed(.food)
    @State private var notes = ""
    @State private var rating = 0
    @State private var cuisine: Cuisine = .other
    @State private var foodType: FoodType = .restaurant
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var photos: [Data] = []
    @State private var locationName: String? = nil
    @State private var locationAddress: String? = nil
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    @State private var showingLocationSearch = false
    @State private var isWishlist: Bool = false
    @State private var showingClearLocation = false
    @State private var showingCamera = false
    @State private var showingLibraryPicker = false
    @State private var showingPhotoSourceOptions = false
    @State private var isEditingPhotos = false
    @State private var previewPhotoData: Data? = nil
    @State private var selectedTrip: Trip? = nil
    @FocusState private var focusedField: Field?

    enum Field {
        case name
    }

    var isEditing: Bool { editingEntry != nil }

    private var selectedCategory: Category? {
        if case .fixed(let cat) = selectedTab { return cat }
        return nil
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                wishlistSection
                nameSection
                locationSection
                if selectedCategory == .food {
                    foodTypeSection
                    if foodType == .restaurant {
                        cuisineSection
                    }
                }
                ratingSection
                photosSection
                notesSection
                categorySection
                tripSection
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(isEditing ? "Edit entry" : "Add entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty)
                }
            }
            .onAppear { loadExisting() }
            .onChange(of: selectedItems) { _, newItems in
                loadPhotos(from: newItems)
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
            .sheet(isPresented: $showingCamera) {
                CameraPicker { data in
                    photos.insert(data, at: 0)
                }
            }
            .photosPicker(isPresented: $showingLibraryPicker, selection: $selectedItems, maxSelectionCount: 20, matching: .images)
            .fullScreenCover(isPresented: Binding(
                get: { previewPhotoData != nil },
                set: { if !$0 { previewPhotoData = nil } }
            )) {
                photoPreview
            }
        }
    }

    // MARK: - Sections

    private var wishlistSection: some View {
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

    private var nameSection: some View {
        Section("Name") {
            TextField("Name", text: $name)
                .focused($focusedField, equals: .name)
                .submitLabel(.done)
                .onSubmit { focusedField = nil }
        }
    }

    private var locationSection: some View {
        Section("Location") {
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
                        Text("Add location")
                            .font(AppTheme.Font.handwritingMedium)
                            .foregroundStyle(AppTheme.Colour.stampRed)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var foodTypePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(FoodType.allCases, id: \.self) { type in
                    Button {
                        foodType = type
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: type.icon)
                                .font(.system(size: 12))
                            Text(type.rawValue)
                                .font(AppTheme.Font.handwritingSmall)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            foodType == type
                            ? AppTheme.Colour.inkDark
                            : AppTheme.Colour.backgroundWarm
                        )
                        .foregroundStyle(
                            foodType == type
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

    private var foodTypeSection: some View {
        Section("Type") {
            foodTypePicker
        }
    }

    private var cuisineSection: some View {
        Section("Cuisine") {
            Picker("Cuisine", selection: $cuisine) {
                ForEach(Cuisine.allCases, id: \.self) { c in
                    Text(c.rawValue).tag(c)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
        }
    }

    private var ratingSection: some View {
        Section("Rating") {
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundStyle(star <= rating ? .orange : .secondary)
                        .font(.title2)
                        .onTapGesture {
                            if rating == star {
                                rating = 0
                            } else {
                                rating = star
                            }
                        }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var photosSection: some View {
        Section {
            if !photos.isEmpty {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                    spacing: 4
                ) {
                    ForEach(Array(photos.enumerated()), id: \.offset) { index, photoData in
                        if let uiImage = UIImage(data: photoData) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 80)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                                    .onTapGesture {
                                        if !isEditingPhotos {
                                            previewPhotoData = photoData
                                        }
                                    }

                                if isEditingPhotos {
                                    Button {
                                        photos.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, .red)
                                    }
                                    .offset(x: 6, y: -6)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Button {
                showingPhotoSourceOptions = true
            } label: {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text(photos.isEmpty ? "Add photos" : "Add more")
                }
                .font(AppTheme.Font.handwritingMedium)
                .foregroundStyle(AppTheme.Colour.stampGreen)
            }
            .confirmationDialog("Add photo", isPresented: $showingPhotoSourceOptions) {
                Button("Take Photo") { showingCamera = true }
                Button("Choose from Library") { showingLibraryPicker = true }
                Button("Cancel", role: .cancel) {}
            }
        } header: {
            HStack {
                Text("Photos")
                Spacer()
                if !photos.isEmpty {
                    Button(isEditingPhotos ? "Done" : "Edit") {
                        isEditingPhotos.toggle()
                    }
                    .font(.footnote)
                    .textCase(nil)
                }
            }
        } footer: {
            if !photos.isEmpty {
                Text(isEditingPhotos ? "Tap the red ✕ to remove a photo" : "Tap a photo to view it, or tap Edit to remove photos")
                    .font(AppTheme.Font.handwritingSmall)
            }
        }
    }

    private var photoPreview: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let data = previewPhotoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                previewPhotoData = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.6))
                    .padding()
            }
        }
        .onTapGesture {
            previewPhotoData = nil
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Any notes...", text: $notes, axis: .vertical)
                .lineLimit(4...8)
        }
    }

    private var categorySection: some View {
        Section("Category") {
            Picker("Category", selection: $selectedTab) {
                ForEach(Category.allCases, id: \.self) { cat in
                    Label(cat.rawValue, systemImage: cat.icon)
                        .tag(CityTab.fixed(cat))
                }
                if let city {
                    ForEach(city.customTabs) { tab in
                        Label {
                            Text(tab.name)
                        } icon: {
                            emojiImage(tab.emoji)
                        }
                        .tag(CityTab.custom(tab))
                    }
                }
            }
        }
    }

    private var tripSection: some View {
        Section {
            Picker("Trip", selection: $selectedTrip) {
                Text("None").tag(Optional<Trip>.none)
                ForEach(trips) { trip in
                    Text(trip.name).tag(Optional(trip))
                }
            }
        } header: {
            Text("Trip")
        } footer: {
            if trips.isEmpty {
                Text("You haven't made any trips yet — add one from the suitcase icon on Home")
                    .font(AppTheme.Font.handwritingSmall)
            } else {
                Text("Optional — tag this entry to look back on it as part of a trip")
                    .font(AppTheme.Font.handwritingSmall)
            }
        }
    }

    // MARK: - Functions

    private func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    photos.insert(data, at: 0)
                }
            }
            selectedItems = []
        }
    }

    private func loadExisting() {
        if let entry = editingEntry {
            name = entry.name
            if let tab = entry.customTab {
                selectedTab = .custom(tab)
            } else {
                selectedTab = .fixed(entry.category)
            }
            notes = entry.notes
            rating = entry.rating
            cuisine = entry.cuisine ?? .other
            foodType = entry.foodType ?? .restaurant
            photos = entry.photos
            locationName = entry.locationName
            locationAddress = entry.locationAddress
            latitude = entry.latitude
            longitude = entry.longitude
            isWishlist = entry.isWishlist
            selectedTrip = entry.trip
        } else if let tab = customTab {
            selectedTab = .custom(tab)
        } else {
            selectedTab = .fixed(initialCategory)
        }
    }
    private func emojiImage(_ emoji: String) -> Image {
        let renderer = ImageRenderer(content: Text(emoji).font(.system(size: 18)))
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "tag")
    }

    private func save() {
        let resolvedCategory: Category
        let resolvedCustomTab: CustomTab?
        switch selectedTab {
        case .fixed(let cat):
            resolvedCategory = cat
            resolvedCustomTab = nil
        case .custom(let tab):
            resolvedCategory = .place   // placeholder — not used for filtering when customTab is set
            resolvedCustomTab = tab
        }

        if let entry = editingEntry {
            entry.name = name
            entry.category = resolvedCategory
            entry.customTab = resolvedCustomTab
            entry.notes = notes
            entry.rating = rating
            entry.cuisine = resolvedCategory == .food && foodType == .restaurant ? cuisine : nil
            entry.foodType = resolvedCategory == .food ? foodType : nil
            entry.photos = photos
            entry.locationName = locationName
            entry.locationAddress = locationAddress
            entry.latitude = latitude
            entry.longitude = longitude
            entry.isWishlist = isWishlist
            entry.trip = selectedTrip
        } else {
            let entry = PlaceEntry(
                name: name,
                category: resolvedCategory,
                notes: notes,
                rating: rating,
                cuisine: resolvedCategory == .food && foodType == .restaurant ? cuisine : nil,
                foodType: resolvedCategory == .food ? foodType : nil,
                city: city,
                locationName: locationName,
                locationAddress: locationAddress,
                latitude: latitude,
                longitude: longitude
            )
            entry.photos = photos
            entry.isWishlist = isWishlist
            entry.customTab = resolvedCustomTab
            entry.trip = selectedTrip
            city?.entries.append(entry)
            modelContext.insert(entry)
        }
        SyncService.autoPushIfLoggedIn(modelContext: modelContext)
        dismiss()
    }
}
