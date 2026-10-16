import SwiftUI
import SwiftData
import PhotosUI

struct EditCityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let city: City

    @State private var cityName: String
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var coverPhotoData: Data? = nil

    init(city: City) {
        self.city = city
        _cityName = State(initialValue: city.name)
        _coverPhotoData = State(initialValue: city.coverPhoto)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("City Name") {
                    TextField("City name", text: $cityName)
                }

                Section("Cover Photo") {
                    if let data = coverPhotoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(10)
                            .listRowInsets(EdgeInsets())
                    }

                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label(
                            coverPhotoData == nil ? "Add Cover Photo" : "Change Cover Photo",
                            systemImage: "photo.on.rectangle"
                        )
                    }

                    if coverPhotoData != nil {
                        Button(role: .destructive) {
                            coverPhotoData = nil
                            selectedPhotoItem = nil
                        } label: {
                            Label("Remove Cover Photo", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Edit City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(cityName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let newItem,
                       let data = try? await newItem.loadTransferable(type: Data.self) {
                        coverPhotoData = data
                    }
                }
            }
        }
    }

    private func save() {
        city.name = cityName.trimmingCharacters(in: .whitespaces)
        city.coverPhoto = coverPhotoData
        try? modelContext.save()
        dismiss()
    }
}
