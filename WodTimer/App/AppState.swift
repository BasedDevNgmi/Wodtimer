import SwiftUI
import Observation

@Observable
final class AppState {
    var isAuthenticated: Bool = false
    var requiresAuth: Bool = false  // App works without auth
    var isPremium: Bool = false
    var userProfile: UserProfile?
    var selectedTimerType: TimerType?
    var showSettings: Bool = false

    func checkPremiumStatus() {
        // StoreKit will update this
    }
}
