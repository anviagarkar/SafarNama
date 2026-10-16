import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let trip: Trip
    @State private var showingEditTrip = false
    @State private var showingQuickAdd = false

    private var sortedEntries: [PlaceEntry] {
        trip.entries.sorted { $0.date < $1.date }
    }

    var body: some View {
        ZStack {
            AppTheme.Colour.background
                .ignoresSafeArea()

            if sortedEntries.isEmpty {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.Colour.inkLight.opacity(0.4))
                    Text("no entries tagged to this trip yet")
                        .font(AppTheme.Font.handwritingMedium)
                        .foregroundStyle(AppTheme.Colour.inkLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Text("tag an entry to this trip when you add or edit it")
                        .font(AppTheme.Font.handwritingSmall)
                        .foregroundStyle(AppTheme.Colour.inkLight.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                List {
                    ForEach(sortedEntries) { entry in
                        NavigationLink(destination: EntryDetailView(entry: entry)) {
                            EntryRowView(entry: entry)
                        }
                        .listRowBackground(AppTheme.Colour.background)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingQuickAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditTrip = true
                }
            }
        }
        .sheet(isPresented: $showingEditTrip) {
            AddTripView(editingTrip: trip)
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAddView(initialCity: nil, initialTrip: trip) { _ in }
        }
    }
}
