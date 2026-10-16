//
//  CityWishlistView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 01/05/2026.
//

import SwiftUI
import SwiftData

struct CityWishlistView: View {
    @Environment(\.modelContext) private var modelContext
    let city: City

    var accentColor: Color { city.accentColor }
    var bgColour: Color { city.bgColour }
    var inkColour: Color { city.inkColour }

    var wishlistEntries: [PlaceEntry] {
        let cityEntries = city.entries.filter { $0.isWishlist }
        let customTabEntries = city.customTabs.flatMap { $0.entries }.filter { $0.isWishlist }
        return (cityEntries + customTabEntries).removingDuplicates()
    }

    var groupedEntries: [(Category, [PlaceEntry])] {
        Category.allCases.compactMap { category in
            let entries = wishlistEntries.filter { $0.category == category }
            return entries.isEmpty ? nil : (category, entries)
        }
    }

    @State private var entryToDelete: PlaceEntry? = nil
    @State private var showingDeleteEntry = false

    var body: some View {
        ZStack {
            bgColour.ignoresSafeArea()

            if wishlistEntries.isEmpty {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 40))
                        .foregroundStyle(accentColor.opacity(0.4))
                    Text("no wishlist entries yet")
                        .font(AppTheme.Font.handwritingLarge)
                        .foregroundStyle(inkColour)
                    Text("add places you want to visit")
                        .font(AppTheme.Font.handwritingSmall)
                        .foregroundStyle(inkColour.opacity(0.6))
                }
            } else {
                List {
                    ForEach(groupedEntries, id: \.0) { category, entries in
                        Section {
                            ForEach(entries) { entry in
                                NavigationLink(destination: EntryDetailView(entry: entry)) {
                                    EntryRowView(entry: entry)
                                }
                                .listRowBackground(bgColour)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        markAsVisited(entry)
                                    } label: {
                                        Label("Visited", systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(accentColor)
                                }
                            }
                            .onDelete { offsets in
                                if let index = offsets.first {
                                    entryToDelete = entries[index]
                                    showingDeleteEntry = true
                                }
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 12))
                                    .padding(6)
                                    .background(accentColor.opacity(0.15))
                                    .clipShape(Circle())
                                Text(category.rawValue.uppercased())
                                    .font(.system(size: 11, weight: .semibold))
                                    .kerning(1.2)
                            }
                            .foregroundStyle(accentColor)
                            .textCase(nil)
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(bgColour)
            }
        }
        .navigationTitle("Wishlist")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete \(entryToDelete?.name ?? "entry")?", isPresented: $showingDeleteEntry) {
            Button("Delete", role: .destructive) {
                if let entry = entryToDelete {
                    deleteEntry(entry)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    private func markAsVisited(_ entry: PlaceEntry) {
        entry.isWishlist = false
    }

    private func deleteEntry(_ entry: PlaceEntry) {
        if let i = city.entries.firstIndex(where: { $0.id == entry.id }) {
            city.entries.remove(at: i)
        }
        modelContext.delete(entry)
    }
}
extension Array where Element: Identifiable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element.ID>()
        return filter { seen.insert($0.id).inserted }
    }
}
