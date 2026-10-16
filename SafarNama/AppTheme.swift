//
//  AppTheme.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 09/04/2026.
//

import SwiftUI

enum AppTheme {
    
    // MARK: - Fonts
    enum Font {
        // Playfair for headings — elegant, vintage
        static let displayLarge  = SwiftUI.Font.custom("PlayfairDisplay-VariableFont_wght", size: 34)
        static let displayLargeBold = SwiftUI.Font.custom("PlayfairDisplay-VariableFont_wght", size: 34, relativeTo: .largeTitle)
        static let displayMedium = SwiftUI.Font.custom("PlayfairDisplay-VariableFont_wght", size: 24)
        static let displaySmall  = SwiftUI.Font.custom("PlayfairDisplay-VariableFont_wght", size: 20)
        static let subtitleLarge = SwiftUI.Font.custom("PlayfairDisplay-Italic-VariableFont_wght", size: 18)
        static let subtitleSmall = SwiftUI.Font.custom("PlayfairDisplay-Italic-VariableFont_wght", size: 15)
        
        // Caveat for notes, labels, whimsical touches — handwriting feel
        static let handwritingLarge  = SwiftUI.Font.custom("Caveat-VariableFont_wght", size: 22)
        static let handwritingMedium = SwiftUI.Font.custom("Caveat-VariableFont_wght", size: 18)
        static let handwritingSmall  = SwiftUI.Font.custom("Caveat-VariableFont_wght", size: 14)
    }
    
    // MARK: - Colours
    enum Colour {
        // Home screen — dusty rose
        static let homeBackground    = Color(hex: "E8D0C8")
        static let homeBackgroundWarm = Color(hex: "DFC4BA")
        
        // Parchment — for city and entry screens
        static let background        = Color(hex: "F2E8D5")
        static let backgroundWarm    = Color(hex: "E8D9BE")
        static let surface           = Color(hex: "FDF6EC")
        
        // Ink tones
        static let inkDark           = Color(hex: "2C2416")
        static let inkMedium         = Color(hex: "5C4A32")
        static let inkLight          = Color(hex: "8B7355")
        
        // Stamp accents
        static let stampRed          = Color(hex: "C44A3A")
        static let stampGreen        = Color(hex: "2A6A3A")
        static let stampBlue         = Color(hex: "2A4A8A")
        static let stampGold         = Color(hex: "C8A850")
        
        // Category colours
        static let food              = Color(hex: "C44A3A")
        static let place             = Color(hex: "2A6A3A")
        static let shop              = Color(hex: "4A2A8A")
    }
    // MARK: - Spacing
    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
    }
    
    // MARK: - Corner radius
    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
    }
}

// MARK: - Hex colour helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = min(1.0, Double((int >> 16) & 0xFF) / 255)
        let g = min(1.0, Double((int >> 8)  & 0xFF) / 255)
        let b = min(1.0, Double(int         & 0xFF) / 255)
        self.init(red: r, green: g, blue: b)
    }
}
