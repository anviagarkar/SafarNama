import SwiftUI
import PhotosUI
import MapKit
import SwiftData

struct EntryDetailView: View {
    let entry: PlaceEntry
    @State private var showingEdit = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingFullPhoto: Data? = nil
    @State private var currentPhotoIndex = 0
    @State private var showingDelete = false
    @State private var mapSnapshot: UIImage? = nil
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var accentColor: Color { entry.city?.accentColor ?? AppTheme.Colour.stampGreen }
    var inkColour: Color { entry.city?.inkColour ?? AppTheme.Colour.inkDark }
    var bgColour: Color { entry.city?.bgColour ?? AppTheme.Colour.background }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: entry.date)
    }

    var body: some View {
        ZStack {
            bgColour.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: — Photo carousel
                    if !entry.photos.isEmpty {
                        TabView(selection: $currentPhotoIndex) {
                            ForEach(Array(entry.photos.enumerated()), id: \.offset) { index, photoData in
                                if let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 280)
                                        .clipped()
                                        .tag(index)
                                        .onTapGesture {
                                            showingFullPhoto = photoData
                                        }
                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                        .frame(height: 280)
                    }

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {

                        // MARK: — Title + meta
                        VStack(alignment: .leading, spacing: 6) {
                            Text(entry.name)
                                .font(AppTheme.Font.displayLarge)
                                .foregroundStyle(inkColour)

                            HStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Image(systemName: entry.category == .food
                                          ? (entry.foodType?.icon ?? entry.category.icon)
                                          : entry.category.icon)
                                        .font(.system(size: 11))
                                    Text(entry.category == .food
                                         ? (entry.foodType?.rawValue ?? entry.category.rawValue)
                                         : entry.category.rawValue)
                                        .font(AppTheme.Font.handwritingSmall)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(accentColor.opacity(0.12))
                                .foregroundStyle(accentColor)
                                .cornerRadius(20)

                                if let cuisine = entry.cuisine, cuisine != .other {
                                    Text(cuisine.rawValue)
                                        .font(AppTheme.Font.handwritingSmall)
                                        .foregroundStyle(inkColour.opacity(0.5))
                                }

                                Spacer()

                                if entry.isWishlist {
                                    HStack(spacing: 4) {
                                        Image(systemName: "bookmark.fill")
                                            .font(.system(size: 11))
                                        Text("want to go")
                                            .font(AppTheme.Font.handwritingSmall)
                                    }
                                    .foregroundStyle(accentColor)
                                }
                            }

                            Text(formattedDate)
                                .font(AppTheme.Font.handwritingSmall)
                                .foregroundStyle(inkColour.opacity(0.4))
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.top, AppTheme.Spacing.md)

                        Divider()
                            .overlay(inkColour.opacity(0.1))
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.bottom, AppTheme.Spacing.sm)
                        
                        if entry.isWishlist {
                            Button {
                                entry.isWishlist = false
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Mark as visited")
                                        .font(AppTheme.Font.handwritingMedium)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(accentColor)
                                .cornerRadius(AppTheme.Radius.md)
                                .padding(.horizontal, AppTheme.Spacing.md)
                            }
                            .buttonStyle(.plain)
                        }

                        // MARK: — Star rating
                        if entry.rating > 0 {
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= entry.rating ? "star.fill" : "star")
                                        .foregroundStyle(star <= entry.rating ? accentColor : inkColour.opacity(0.2))
                                        .font(.system(size: 18))
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.md)
                        }

                        // MARK: — Notes
                        if !entry.notes.isEmpty {
                            Text(entry.notes)
                                .font(AppTheme.Font.handwritingMedium)
                                .foregroundStyle(inkColour.opacity(0.85))
                                .lineSpacing(6)
                                .padding(.horizontal, AppTheme.Spacing.md)
                        }

                        // MARK: — Location
                        if let address = entry.locationAddress {
                            VStack(alignment: .leading, spacing: 8) {
                                if let snapshot = mapSnapshot {
                                    Image(uiImage: snapshot)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                        .padding(.horizontal, AppTheme.Spacing.md)
                                }

                                Button {
                                    openInMaps()
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundStyle(AppTheme.Colour.stampRed)
                                            .font(.system(size: 20))
                                        Text(address)
                                            .font(AppTheme.Font.handwritingSmall)
                                            .foregroundStyle(inkColour.opacity(0.5))
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                            .foregroundStyle(accentColor.opacity(0.5))
                                            .font(.system(size: 14))
                                    }
                                    .padding(AppTheme.Spacing.md)
                                    .background(accentColor.opacity(0.07))
                                    .cornerRadius(AppTheme.Radius.md)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, AppTheme.Spacing.md)
                            }
                            .onAppear {
                                generateMapSnapshot()
                            }
                        }
                        // MARK: — Add photos
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: 20,
                            matching: .images
                        ) {
                            HStack(spacing: 6) {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text(entry.photos.isEmpty ? "Add photos" : "Add more photos")
                                    .font(AppTheme.Font.handwritingMedium)
                            }
                            .foregroundStyle(accentColor.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.top, AppTheme.Spacing.sm)
                            .padding(.horizontal, AppTheme.Spacing.md)
                        }

                    }
                }
            }
            .ignoresSafeArea(edges: entry.photos.isEmpty ? [] : .top)

            // MARK: — Full screen photo overlay
            if let photoData = showingFullPhoto,
               let uiImage = UIImage(data: photoData) {
                ZStack {
                    Color.black.opacity(0.95)
                        .ignoresSafeArea()
                        .onTapGesture { showingFullPhoto = nil }

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding()

                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                showingFullPhoto = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.white)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button("Edit") { showingEdit = true }
                        .foregroundStyle(accentColor)
                    Button {
                        showingDelete = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(AppTheme.Colour.stampRed)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditEntryView(city: entry.city, editingEntry: entry)
        }
        .alert("Delete \(entry.name)?", isPresented: $showingDelete) {
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .onChange(of: selectedItems) { _, newItems in
            loadPhotos(from: newItems)
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    entry.photos.insert(data, at: 0)
                }
            }
            selectedItems = []
        }
    }

    private func openInMaps() {
        guard let address = entry.locationAddress else { return }
        if let lat = entry.latitude, let lon = entry.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            mapItem.name = entry.locationName ?? address
            mapItem.openInMaps()
        } else {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { placemarks, _ in
                if let placemark = placemarks?.first {
                    let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                    mapItem.name = entry.locationName ?? address
                    mapItem.openInMaps()
                }
            }
        }
    }
    private func deleteEntry() {
        if let city = entry.city {
                city.entries.removeAll { $0.id == entry.id }
            }
            modelContext.delete(entry)
            SyncService.autoPushIfLoggedIn(modelContext: modelContext)
            dismiss()
    }

    private func generateMapSnapshot() {
        guard let lat = entry.latitude, let lon = entry.longitude else { return }
        let options = MKMapSnapshotter.Options()
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        options.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        options.size = CGSize(width: 400, height: 200)
        options.mapType = .standard

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, _ in
            guard let snapshot = snapshot else { return }

            let image = snapshot.image
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: .zero)

            let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            pinView.pinTintColor = UIColor(AppTheme.Colour.stampRed)
            let pinImage = pinView.image
            var point = snapshot.point(for: coordinate)
            point.x -= (pinView.bounds.width / 2) - pinView.centerOffset.x
            point.y -= pinView.bounds.height + pinView.centerOffset.y
            pinImage?.draw(at: point)

            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            DispatchQueue.main.async {
                mapSnapshot = finalImage
            }
        }
    }
}
