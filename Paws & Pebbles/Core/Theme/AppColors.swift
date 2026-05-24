import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @Published var isDarkMode: Bool

    init() {
        self.isDarkMode = UserDefaults.standard.object(forKey: "appTheme") as? Bool ?? true
    }

    func toggle() {
        isDarkMode.toggle()
        UserDefaults.standard.set(isDarkMode, forKey: "appTheme")
    }
}

enum AppColors {
    private static var isDark: Bool { ThemeManager.shared.isDarkMode }

    // Backgrounds
    static var bgDeep: Color {
        isDark ? Color(hex: "#070D14") : Color(hex: "#F2F5F3")
    }
    static var cardBg: Color {
        isDark ? Color(hex: "#0D151F") : Color(hex: "#FFFFFF")
    }
    static var cardBorder: Color {
        isDark ? Color(hex: "#3DBEB5").opacity(0.08) : Color(hex: "#3DBEB5").opacity(0.12)
    }
    static var cardActive: Color {
        isDark ? Color(hex: "#3DBEB5").opacity(0.12) : Color(hex: "#3DBEB5").opacity(0.18)
    }

    // Accent (same in both themes)
    static let river = Color(hex: "#3DBEB5")
    static let riverDim = Color(hex: "#3DBEB5").opacity(0.4)
    static let gold = Color(hex: "#E8D5A3")

    // Text
    static var textPrimary: Color {
        isDark ? Color(hex: "#D4E4DC") : Color(hex: "#1A2B24")
    }
    static var textMuted: Color {
        isDark ? Color(hex: "#6B8A80") : Color(hex: "#5A7A6E")
    }
    static var textDim: Color {
        isDark ? Color(hex: "#3A5249") : Color(hex: "#9AB0A6")
    }

    // Stone Colors (same in both)
    static let sandstone = Color(hex: "#C4A882")
    static let slate = Color(hex: "#6B7D8A")
    static let mossyStone = Color(hex: "#7A8B6F")
    static let roseQuartz = Color(hex: "#C9A0A0")
    static let obsidian = Color(hex: "#505060")
}
