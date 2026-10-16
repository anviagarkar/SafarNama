import SwiftUI
import SwiftData

struct AddTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var editingTrip: Trip? = nil

    @State private var name = ""
    @State private var hasDates = false
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var duplicateError = false
    @FocusState private var focusedField: Field?

    enum Field {
        case name
    }

    var isEditing: Bool { editingTrip != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip name") {
                    TextField("e.g. Summer in Europe", text: $name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                }

                Section {
                    Toggle("Add dates", isOn: $hasDates.animation())
                    if hasDates {
                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                        DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                } footer: {
                    Text("Dates are optional — you can add entries to a trip anytime")
                        .font(AppTheme.Font.handwritingSmall)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(isEditing ? "Edit trip" : "New trip")
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
            .alert("Trip already exists", isPresented: $duplicateError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You already have a trip with this name.")
            }
        }
    }

    private func loadExisting() {
        if let trip = editingTrip {
            name = trip.name
            if let start = trip.startDate, let end = trip.endDate {
                hasDates = true
                startDate = start
                endDate = end
            }
        }
    }

    private func save() {
        let allTrips = (try? modelContext.fetch(FetchDescriptor<Trip>())) ?? []
        let isDuplicate = allTrips.contains { existing in
            existing.name.lowercased() == name.lowercased() &&
            existing.persistentModelID != editingTrip?.persistentModelID
        }
        if isDuplicate {
            duplicateError = true
            return
        }

        if let trip = editingTrip {
            trip.name = name
            trip.startDate = hasDates ? startDate : nil
            trip.endDate = hasDates ? endDate : nil
        } else {
            let trip = Trip(
                name: name,
                startDate: hasDates ? startDate : nil,
                endDate: hasDates ? endDate : nil
            )
            modelContext.insert(trip)
        }
        SyncService.autoPushIfLoggedIn(modelContext: modelContext)
        dismiss()
    }
}
