import SwiftUI
import SwiftData

@main
struct WodTimerApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [WorkoutSession.self, Preset.self])
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.isAuthenticated || !appState.requiresAuth {
                HomeView()
            } else {
                SignInView()
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
    }
}
