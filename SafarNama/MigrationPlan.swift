//
//  MigrationPlan.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 23/06/2026.
//

import SwiftData

enum SafarNamaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SafarNamaSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum SafarNamaSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Country.self, City.self, PlaceEntry.self, CustomTab.self]
    }
}
