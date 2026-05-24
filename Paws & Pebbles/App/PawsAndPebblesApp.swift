import SwiftUI
import SwiftData

@main
struct PawsAndPebblesApp: App {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [
            Memory.self, LoveNote.self, Album.self,
            Countdown.self, Puppy.self
        ])
    }
}
