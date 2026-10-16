//
//  Item.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 05/04/2026.
//

import SwiftUI
import SwiftData

// MARK: - Enums

enum Category: String, Codable, CaseIterable {
    case food = "Food"
    case place = "Place"
    case shop = "Shop"

    var icon: String {
        switch self {
        case .food:  return "fork.knife"
        case .place: return "mappin"
        case .shop:  return "bag"
        }
    }

    var color: Color {
        switch self {
        case .food:  return AppTheme.Colour.food
        case .place: return AppTheme.Colour.place
        case .shop:  return AppTheme.Colour.shop
        }
    }

    var themeColour: Color {
        switch self {
        case .food:  return AppTheme.Colour.food
        case .place: return AppTheme.Colour.place
        case .shop:  return AppTheme.Colour.shop
        }
    }
}

enum FoodType: String, Codable, CaseIterable {
    case restaurant  = "Restaurant"
    case cafe        = "Café"
    case bar         = "Bar"
    case streetFood  = "Street Food"
    case dessert     = "Dessert"
    case other       = "Other"

    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .cafe:       return "cup.and.saucer"
        case .bar:        return "wineglass"
        case .streetFood: return "bag"
        case .dessert:    return "birthday.cake"
        case .other:      return "star"
        }
    }
}

enum Cuisine: String, Codable, CaseIterable {
    case italian     = "Italian"
    case japanese    = "Japanese"
    case irish       = "Irish"
    case indian      = "Indian"
    case chinese     = "Chinese"
    case mexican     = "Mexican"
    case thai        = "Thai"
    case middleEastern = "Middle Eastern"
    case american    = "American"
    case french      = "French"
    case other       = "Other"
}
enum CityTab: Hashable {
    case fixed(Category)
    case custom(CustomTab)

    var title: String {
        switch self {
        case .fixed(let cat):  return cat.rawValue
        case .custom(let tab): return tab.name
        }
    }

    var icon: String {
        switch self {
        case .fixed(let cat):  return cat.icon
        case .custom(let tab): return tab.emoji
        }
    }

    var isEmoji: Bool {
        if case .custom = self { return true }
        return false
    }
}

// MARK: - Country colour palette
enum CountryColour: String, CaseIterable {
    case dustyRose    = "dustyRose"
    case sageGreen    = "sageGreen"
    case terracotta   = "terracotta"
    case navy         = "navy"
    case lavender     = "lavender"
    case burntOrange  = "burntOrange"
    case dustyTeal    = "dustyTeal"
    case burgundy     = "burgundy"
    case olive        = "olive"
    case slateBlue    = "slateBlue"

    var backgroundColour: Color {
        switch self {
        case .dustyRose:   return Color(hex: "E6CDD1")  // light
        case .sageGreen:   return Color(hex: "C9D6C0")  // light
        case .terracotta:  return Color(hex: "E3BBA4")  // light
        case .navy:        return Color(hex: "15253F")  // dark
        case .lavender:    return Color(hex: "D4C3E8")  // light
        case .burntOrange: return Color(hex: "E8C190")  // light
        case .dustyTeal:   return Color(hex: "A9C7C5")  // light
        case .burgundy:    return Color(hex: "4A1420")  // dark
        case .olive:       return Color(hex: "C3CC94")  // light
        case .slateBlue:   return Color(hex: "242F3D")  // dark
        }
    }

    var inkColour: Color {
        switch self {
        case .dustyRose:   return Color(hex: "3B1620")  // deep wine on dusty rose
        case .sageGreen:   return Color(hex: "1E3322")  // deep forest on sage
        case .terracotta:  return Color(hex: "3C1B0C")  // deep umber on terracotta
        case .navy:        return Color(hex: "EFE3CB")  // warm parchment on navy
        case .lavender:    return Color(hex: "2A1B47")  // deep plum on lavender
        case .burntOrange: return Color(hex: "3D230C")  // deep umber on burnt orange
        case .dustyTeal:   return Color(hex: "122424")  // deep teal-black on dusty teal
        case .burgundy:    return Color(hex: "F2E6CC")  // warm parchment on burgundy
        case .olive:       return Color(hex: "202608")  // deep olive-black on olive
        case .slateBlue:   return Color(hex: "EEE6D2")  // warm parchment on slate blue
        }
    }

    var accentColour: Color {
        switch self {
        case .dustyRose:   return Color(hex: "2E6B5A")  // deep jade — cool complement to warm pink
        case .sageGreen:   return Color(hex: "8C3A5C")  // deep berry — warm complement to cool green
        case .terracotta:  return Color(hex: "1F5A6E")  // deep teal-blue — cool complement to warm orange
        case .navy:        return Color(hex: "E8A8BA")  // dusty pink — warm complement to cool navy
        case .lavender:    return Color(hex: "8C5A1E")  // deep amber — warm complement to cool purple
        case .burntOrange: return Color(hex: "1F5A66")  // deep teal — cool complement to warm orange
        case .dustyTeal:   return Color(hex: "A8472E")  // deep rust — warm complement to cool teal
        case .burgundy:    return Color(hex: "9CC9B0")  // light sage-mint — cool complement to warm burgundy
        case .olive:       return Color(hex: "5A3F7A")  // deep violet — cool complement to warm olive
        case .slateBlue:   return Color(hex: "E0A878")  // warm peach — warm complement to cool slate
        }
    }

    // Solid, opaque card colour — a light pastel tint of this theme's accent
    // hue, baked in directly (no SwiftUI .opacity()/alpha blending). Used for
    // entry row backgrounds so each row reads as a flat, distinct colour
    // instead of a translucent wash over whatever's behind it.
    var cardColour: Color {
        switch self {
        case .dustyRose:   return Color(hex: "CFE3DA")  // light jade tint
        case .sageGreen:   return Color(hex: "E8D2DC")  // light berry tint
        case .terracotta:  return Color(hex: "CDE0E6")  // light teal tint
        case .navy:        return Color(hex: "F3D9E1")  // light dusty-pink tint
        case .lavender:    return Color(hex: "EDDCC2")  // light amber tint
        case .burntOrange: return Color(hex: "CEE0E2")  // light teal tint
        case .dustyTeal:   return Color(hex: "EFD6CC")  // light rust tint
        case .burgundy:    return Color(hex: "DCEEE4")  // light mint tint
        case .olive:       return Color(hex: "E2D7EC")  // light violet tint
        case .slateBlue:   return Color(hex: "F2DEC8")  // light peach tint
        }
    }

    var name: String {
        switch self {
        case .dustyRose:   return "Dusty rose"
        case .sageGreen:   return "Sage green"
        case .terracotta:  return "Terracotta"
        case .navy:        return "Navy"
        case .lavender:    return "Lavender"
        case .burntOrange: return "Burnt orange"
        case .dustyTeal:   return "Dusty teal"
        case .burgundy:    return "Burgundy"
        case .olive:       return "Olive"
        case .slateBlue:   return "Slate blue"
        }
    }
}


// MARK: - Models

@Model
final class Country {
    var name: String
    var isHome: Bool
    var colorHex: String
    @Relationship(deleteRule: .cascade) var cities: [City] = []

    init(name: String, isHome: Bool = false, colorHex: String = "sageGreen") {
        self.name = name
        self.isHome = isHome
        self.colorHex = colorHex
    }

    var countryColour: CountryColour {
        CountryColour(rawValue: colorHex) ?? .sageGreen
    }

    var backgroundColour: Color { countryColour.backgroundColour }
    var inkColour: Color { countryColour.inkColour }
    var accentColor: Color { countryColour.accentColour }
    var cardColour: Color { countryColour.cardColour }
}

@Model
final class City {
    var id: UUID = UUID()   // ← add this
    var name: String
    var country: Country?
    @Relationship(deleteRule: .cascade) var entries: [PlaceEntry] = []
    @Relationship(deleteRule: .cascade) var customTabs: [CustomTab] = []
    @Attribute(.externalStorage) var coverPhoto: Data? = nil

    init(name: String, country: Country? = nil) {
        self.name = name
        self.country = country
    }
}


@Model
final class PlaceEntry {
    var name: String
    var category: Category
    var notes: String
    var rating: Int
    var cuisine: Cuisine?
    var foodType: FoodType?
    var date: Date
    var city: City?
    var customTab: CustomTab?   // ← new
    var trip: Trip?             // ← new: optional, assigned after creation like customTab
    var locationName: String?
    var locationAddress: String?
    var latitude: Double?
    var longitude: Double?
    var isWishlist: Bool = false
    @Attribute(.externalStorage) var photos: [Data] = []

    init(
        name: String,
        category: Category,
        notes: String = "",
        rating: Int = 0,
        cuisine: Cuisine? = nil,
        foodType: FoodType? = nil,
        date: Date = Date(),
        city: City? = nil,
        locationName: String?,
        locationAddress: String?,
        latitude: Double?,
        longitude: Double?,
    ) {
        self.name = name
        self.category = category
        self.notes = notes
        self.rating = rating
        self.cuisine = cuisine
        self.foodType = foodType
        self.date = date
        self.city = city
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude
        self.longitude = longitude
    }
}

@Model
final class CustomTab {
    var name: String
    var emoji: String
    var city: City?
    @Relationship(deleteRule: .cascade, inverse: \PlaceEntry.customTab) var entries: [PlaceEntry] = []

    init(name: String, emoji: String, city: City? = nil) {
        self.name = name
        self.emoji = emoji
        self.city = city
    }
}

@Model
final class Trip {
    var name: String
    var startDate: Date?
    var endDate: Date?
    @Relationship(deleteRule: .nullify, inverse: \PlaceEntry.trip) var entries: [PlaceEntry] = []

    init(name: String, startDate: Date? = nil, endDate: Date? = nil) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
}

struct LocationResult {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}
extension City {
    var accentColor: Color { country?.accentColor ?? AppTheme.Colour.stampGreen }
    var inkColour: Color { country?.inkColour ?? AppTheme.Colour.inkDark }
    var bgColour: Color { country?.backgroundColour ?? AppTheme.Colour.background }
    var cardColour: Color { country?.cardColour ?? AppTheme.Colour.surface }
}
