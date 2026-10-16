import SwiftUI

struct EntryRowView: View {
    let entry: PlaceEntry

    var inkColour: Color { entry.city?.inkColour ?? AppTheme.Colour.inkDark }
    var accentColor: Color { entry.city?.accentColor ?? AppTheme.Colour.stampGreen }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .stroke(accentColor, lineWidth: 1)
                    .frame(width: 40, height: 40)
                Image(systemName: entry.isWishlist ? "bookmark.fill" : entry.category.icon)
                    .foregroundStyle(accentColor)
                    .font(.system(size: 15))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(AppTheme.Font.displaySmall)
                    .foregroundStyle(inkColour)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    if entry.category == .food {
                        if let cuisine = entry.cuisine {
                            Text(cuisine.rawValue)
                        } else if let foodType = entry.foodType {
                            Text(foodType.rawValue)
                        }
                    }
                    if entry.rating > 0 && !entry.isWishlist {
                        if entry.category == .food && (entry.cuisine != nil || entry.foodType != nil) {
                            Text("·")
                        }
                        Text(String(repeating: "★", count: entry.rating))
                            .foregroundStyle(accentColor)
                    }
                }
                .font(AppTheme.Font.handwritingSmall)
                .foregroundStyle(inkColour.opacity(0.75))

                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(AppTheme.Font.handwritingSmall)
                        .foregroundStyle(inkColour.opacity(0.6))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                .stroke(accentColor, lineWidth: 1.5)
        )
    }
}
