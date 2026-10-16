//
//  CountryCardView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 09/04/2026.
//

import SwiftUI

struct CountryCardView: View {
    let country: Country

    var totalEntries: Int {
        country.cities.flatMap { $0.entries }.filter { !$0.isWishlist }.count
    }

    var body: some View {
        HStack(spacing: 0) {

            // Subtle colour accent bar
            Rectangle()
                .fill(country.backgroundColour)
                .frame(width: 4)
                .cornerRadius(2)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(country.name)
                            .font(AppTheme.Font.displaySmall)
                            .foregroundStyle(AppTheme.Colour.inkDark)
                        if country.isHome {
                            Text("home")
                                .font(AppTheme.Font.handwritingSmall)
                                .foregroundStyle(country.accentColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(country.accentColor.opacity(0.12))
                                .cornerRadius(AppTheme.Radius.sm)
                        }
                    }
                    Text("\(country.cities.count) \(country.cities.count == 1 ? "city" : "cities") · \(totalEntries) \(totalEntries == 1 ? "place" : "places")")
                        .font(AppTheme.Font.handwritingSmall)
                        .foregroundStyle(AppTheme.Colour.inkLight)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.Colour.inkLight.opacity(0.4))
                    .font(.system(size: 12))
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colour.surface)
        .cornerRadius(AppTheme.Radius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .stroke(AppTheme.Colour.inkLight.opacity(0.1), lineWidth: 1)
        )
    }
}
