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

    init() {
        Task { await checkPremiumStatus() }
    }

    func checkPremiumStatus() async {
        await StoreService.shared.checkEntitlements()
        isPremium = StoreService.shared.isPremium
    }
}
