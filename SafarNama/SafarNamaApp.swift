//
//  SafarNamaApp.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 05/04/2026.
//

import SwiftUI
import SwiftData

@main
struct SafarNamaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Country.self,
            City.self,
            PlaceEntry.self,
            CustomTab.self,
        ])
        let modelConfiguration = ModelConfiguration(
            "SafarNama1",
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: SafarNamaMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            print("SwiftData error: \(error)")
            let fallback = ModelConfiguration(isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
