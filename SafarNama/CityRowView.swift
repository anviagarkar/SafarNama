//
//  CityRowView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 05/04/2026.
//

import SwiftUI

struct CityRowView: View {
    let city: City
    let accentColor: Color
    let inkColour: Color

    var entryCount: Int { city.entries.count }
    var foodCount: Int { city.entries.filter { $0.category == .food && $0.customTab == nil }.count }
    var placeCount: Int { city.entries.filter { $0.category == .place && $0.customTab == nil }.count }
    var shopCount: Int { city.entries.filter { $0.category == .shop && $0.customTab == nil }.count }

    var customTabEntryCount: Int {
        city.customTabs.reduce(0) { $0 + $1.entries.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(city.name)
                .font(AppTheme.Font.displaySmall)
                .foregroundStyle(inkColour)

            if entryCount == 0 {
                Text("no entries yet")
                    .font(AppTheme.Font.handwritingSmall)
                    .foregroundStyle(inkColour.opacity(0.6))
            } else {
                HStack(spacing: 8) {
                    if foodCount > 0 {
                        Label("\(foodCount)", systemImage: "fork.knife")
                    }
                    if placeCount > 0 {
                        Label("\(placeCount)", systemImage: "mappin")
                    }
                    if shopCount > 0 {
                        Label("\(shopCount)", systemImage: "bag")
                    }
                    if customTabEntryCount > 0 {
                        Label("\(customTabEntryCount)", systemImage: "tag")
                    }
                }
                .font(AppTheme.Font.handwritingSmall)
                .foregroundStyle(accentColor)
            }
        }
        .padding(.vertical, 4)
    }
}
