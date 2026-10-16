import SwiftUI
import SwiftData

struct TripsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.name) private var trips: [Trip]
    @State private var showingAddTrip = false
    @State private var tripToDelete: Trip? = nil
    @State private var showingDeleteTrip = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colour.background
                    .ignoresSafeArea()

                if trips.isEmpty {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.Colour.inkLight.opacity(0.4))
                        Text("no trips yet")
                            .font(AppTheme.Font.handwritingLarge)
                            .foregroundStyle(AppTheme.Colour.inkLight)
                        Text("tap + to start one")
                            .font(AppTheme.Font.handwritingSmall)
                            .foregroundStyle(AppTheme.Colour.inkLight.opacity(0.7))
                    }
                } else {
                    List {
                        ForEach(trips) { trip in
                            NavigationLink(destination: TripDetailView(trip: trip)) {
                                tripRow(trip)
                            }
                            .listRowBackground(AppTheme.Colour.background)
                        }
                        .onDelete { offsets in
                            if let index = offsets.first {
                                tripToDelete = trips[index]
                                showingDeleteTrip = true
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Trips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTrip = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(AppTheme.Colour.inkDark)
                    }
                }
            }
            .sheet(isPresented: $showingAddTrip) {
                AddTripView()
            }
            .alert("Delete \(tripToDelete?.name ?? "trip")?", isPresented: $showingDeleteTrip) {
                Button("Delete", role: .destructive) {
                    if let trip = tripToDelete {
                        modelContext.delete(trip)
                        SyncService.autoPushIfLoggedIn(modelContext: modelContext)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Entries in this trip won't be deleted — they'll stay in their countries and cities, they just won't be tagged to this trip anymore.")
            }
        }
    }

    private func tripRow(_ trip: Trip) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(trip.name)
                .font(AppTheme.Font.displaySmall)
                .foregroundStyle(AppTheme.Colour.inkDark)

            HStack(spacing: 6) {
                if let dateRange = formattedDateRange(trip) {
                    Text(dateRange)
                }
                if let dateRange = formattedDateRange(trip), !trip.entries.isEmpty {
                    Text("·")
                }
                if !trip.entries.isEmpty {
                    Text("\(trip.entries.count) \(trip.entries.count == 1 ? "entry" : "entries")")
                }
            }
            .font(AppTheme.Font.handwritingSmall)
            .foregroundStyle(AppTheme.Colour.inkLight)
        }
        .padding(.vertical, 4)
    }

    private func formattedDateRange(_ trip: Trip) -> String? {
        guard let start = trip.startDate else { return nil }
        guard let end = trip.endDate else {
            return start.formatted(date: .abbreviated, time: .omitted)
        }
        return "\(start.formatted(date: .abbreviated, time: .omitted)) – \(end.formatted(date: .abbreviated, time: .omitted))"
    }
}
