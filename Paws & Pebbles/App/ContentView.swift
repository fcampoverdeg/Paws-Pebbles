import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @AppStorage("lockDelay") private var lockDelay = 0
    @State private var isUnlocked = false
    @State private var backgroundedAt: Date?

    var body: some View {
        ZStack {
            if isUnlocked {
                MainTabView()
            } else {
                LockScreenView(isUnlocked: $isUnlocked)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                backgroundedAt = Date()
            case .active:
                if let bg = backgroundedAt, isUnlocked {
                    let elapsed = Int(Date().timeIntervalSince(bg))
                    if elapsed >= lockDelay {
                        isUnlocked = false
                    }
                }
                backgroundedAt = nil
            default:
                break
            }
        }
        .onAppear {
            DataService.loadInitialDataIfNeeded(context: modelContext)
        }
    }
}
