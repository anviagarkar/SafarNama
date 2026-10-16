import SwiftUI
import SwiftData

struct AddCityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let country: Country
    @State private var name = ""
    @State private var duplicateError = false
    @FocusState private var focusedField: Field?

    enum Field {
        case name
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("City name") {
                    TextField("e.g. Dublin", text: $name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                }
                Section {
                    Text("Adding to \(country.name)")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add city")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCity()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .alert("City already exists", isPresented: $duplicateError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You already have a city with this name in \(country.name).")
            }
        }
    }

    private func saveCity() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if country.cities.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            duplicateError = true
            return
        }
        let city = City(name: name, country: country)
        country.cities.append(city)
        modelContext.insert(city)
        SyncService.autoPushIfLoggedIn(modelContext: modelContext)
        dismiss()
    }
}
