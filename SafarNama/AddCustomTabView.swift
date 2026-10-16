//
//  AddCustomTabView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 12/04/2026.
//

import SwiftUI
import SwiftData

struct AddCustomTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let city: City

    @State private var name = ""
    @State private var emoji = ""
    @State private var duplicateError = false
    @FocusState private var focusedField: Field?

    enum Field {
        case emoji, name
    }

    let suggestedTabs: [(String, String)] = [
        ("Stays", "🛏️"),
        ("Transport", "🚇"),
        ("Nightlife", "🌙"),
        ("Experiences", "🎭"),
        ("Shopping", "🛍️"),
        ("Coffee", "☕"),
        ("Nature", "🌿"),
        ("Art", "🎨"),
        ("Music", "🎵"),
        ("Sports", "⚽"),
        ("Markets", "🏪"),
        ("Beaches", "🏖️")
    ]

    var accentColor: Color {
        city.country?.accentColor ?? AppTheme.Colour.stampGreen
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Quick add") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 3),
                        spacing: 8
                    ) {
                        ForEach(suggestedTabs, id: \.0) { tab in
                            Button {
                                name = tab.0
                                emoji = tab.1
                            } label: {
                                VStack(spacing: 4) {
                                    Text(tab.1)
                                        .font(.title2)
                                    Text(tab.0)
                                        .font(AppTheme.Font.handwritingSmall)
                                        .foregroundStyle(
                                            name == tab.0
                                            ? accentColor
                                            : AppTheme.Colour.inkMedium
                                        )
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    name == tab.0
                                    ? accentColor.opacity(0.12)
                                    : AppTheme.Colour.backgroundWarm
                                )
                                .cornerRadius(AppTheme.Radius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(
                                            name == tab.0 ? accentColor : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Or create your own") {
                    HStack {
                        TextField("Emoji", text: $emoji)
                            .frame(width: 44)
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .emoji)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .name }
                            .onChange(of: emoji) { _, newValue in
                                if newValue.count > 2 {
                                    emoji = String(newValue.prefix(2))
                                }
                            }
                        Divider()
                        TextField("Tab name", text: $name)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                    }
                }

                if !name.isEmpty {
                    Section("Preview") {
                        HStack(spacing: 6) {
                            Text(emoji.isEmpty ? "📌" : emoji)
                            Text(name)
                                .font(AppTheme.Font.handwritingMedium)
                                .foregroundStyle(accentColor)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add tab")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled(name.isEmpty)
                }
            }
            .alert("Tab already exists", isPresented: $duplicateError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You already have a tab called \(name) in this city.")
            }
        }
    }

    private func save() {
        // Check for duplicate tab name
        if city.customTabs.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            duplicateError = true
            return
        }
        let tab = CustomTab(
            name: name,
            emoji: emoji.isEmpty ? "📌" : emoji,
            city: city
        )
        city.customTabs.append(tab)
        modelContext.insert(tab)
        SyncService.autoPushIfLoggedIn(modelContext: modelContext)
        dismiss()
    }
}
