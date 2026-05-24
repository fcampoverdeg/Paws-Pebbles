import SwiftUI

enum AppFonts {
    // Display — Cormorant Garamond
    static let appTitle = Font.custom("CormorantGaramond-Light", size: 30)
    static let appTitleItalic = Font.custom("CormorantGaramond-Italic", size: 30)
    static let memoryTitle = Font.custom("CormorantGaramond-Regular", size: 16)
    static let detailTitle = Font.custom("CormorantGaramond-Regular", size: 30)

    // UI — Outfit
    static let subtitle = Font.custom("Outfit-ExtraLight", size: 9)
    static let dateLabel = Font.custom("Outfit-Light", size: 8)
    static let dateLabelDetail = Font.custom("Outfit-Light", size: 9)
    static let body = Font.custom("Outfit-Light", size: 12)
    static let bodyLarge = Font.custom("Outfit-Light", size: 14)
    static let button = Font.custom("Outfit-Light", size: 10)
    static let navLabel = Font.custom("Outfit-Light", size: 7)
    static let badge = Font.custom("Outfit-Light", size: 9)
    static let mood = Font.custom("Outfit-Light", size: 10)
    static let caption = Font.custom("Outfit-Light", size: 11)
    static let counter = Font.custom("Outfit-Light", size: 10)
    static let hint = Font.custom("Outfit-ExtraLight", size: 10)
    static let galleryLabel = Font.custom("Outfit-Light", size: 9)
    static let location = Font.custom("Outfit-Light", size: 10)

    // Fallbacks (use system if custom fonts aren't loaded yet)
    static let memoryTitleFallback = Font.system(size: 16, weight: .regular, design: .serif)
    static let detailTitleFallback = Font.system(size: 30, weight: .regular, design: .serif)
}
