import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @State private var isUnlocked = false
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {
            if isUnlocked {
                mainApp
            } else {
                LockScreenView(isUnlocked: $isUnlocked)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                isUnlocked = false
            }
        }
        .onAppear {
            DataService.loadInitialDataIfNeeded(context: modelContext)
        }
        .preferredColorScheme(.dark)
    }

    private var mainApp: some View {
        MainTabView()
    }
}
