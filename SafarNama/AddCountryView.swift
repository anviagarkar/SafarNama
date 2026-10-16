import SwiftUI
import SwiftData

struct AddCountryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var editingCountry: Country? = nil

    @State private var name = ""
    @State private var isHome = false
    @State private var selectedColour: CountryColour = .sageGreen
    @State private var duplicateError = false
    @FocusState private var focusedField: Field?

    enum Field {
        case name
    }

    var isEditing: Bool { editingCountry != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("e.g. 🇮🇪 Ireland", text: $name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                } header: {
                    Text("Country name")
                } footer: {
                    Text("You can include the flag emoji in the name")
                        .font(AppTheme.Font.handwritingSmall)
                }

                Section {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 5),
                        spacing: 12
                    ) {
                        ForEach(CountryColour.allCases, id: \.self) { colour in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(colour.backgroundColour)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                colour.accentColour,
                                                lineWidth: selectedColour == colour ? 2.5 : 0
                                            )
                                    )
                                    .onTapGesture { selectedColour = colour }
                                Text(colour.name)
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Colour theme")
                } footer: {
                    Text("Themes all screens for this country")
                        .font(AppTheme.Font.handwritingSmall)
                }

                Section {
                    Toggle("This is my home country", isOn: $isHome)
                } footer: {
                    Text("Home countries appear at the top of your list")
                        .font(AppTheme.Font.handwritingSmall)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(isEditing ? "Edit country" : "Add country")
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
            .alert("Country already exists", isPresented: $duplicateError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You already have a country with this name. Each country must have a unique name.")
            }
        }
    }

    private func loadExisting() {
        if let country = editingCountry {
            name = country.name
            isHome = country.isHome
            selectedColour = country.countryColour
        }
    }

    private func save() {
        // Check for duplicate name — excludes the country currently being edited
        let allCountries = (try? modelContext.fetch(FetchDescriptor<Country>())) ?? []
        let isDuplicate = allCountries.contains { existing in
            existing.name.lowercased() == name.lowercased() &&
            existing.persistentModelID != editingCountry?.persistentModelID
        }
        if isDuplicate {
            duplicateError = true
            return
        }

        if let country = editingCountry {
            country.name = name
            country.isHome = isHome
            country.colorHex = selectedColour.rawValue
        } else {
            let country = Country(
                name: name,
                isHome: isHome,
                colorHex: selectedColour.rawValue
            )
            modelContext.insert(country)
        }
        SyncService.autoPushIfLoggedIn(modelContext: modelContext)
        dismiss()
    }
}
