import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 4) {
                    Text("wodtimer")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)
                        .tracking(-1)
                    Text("TIMER")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .tracking(6)
                }
                .padding(.bottom, 20)

                Text("Sign in to sync your workouts\nacross all your devices")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)

                Spacer()

                // Apple Sign In
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let auth):
                        if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                            Task {
                                await AuthService.shared.signInWithApple(credential: credential)
                                appState.isAuthenticated = AuthService.shared.isAuthenticated
                            }
                        }
                    case .failure:
                        break
                    }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 52)
                .cornerRadius(26)
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, 16)

                // Skip
                Button {
                    appState.requiresAuth = false
                    appState.isAuthenticated = false
                } label: {
                    Text("Continue without signing in")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textMuted)
                }
                .padding(.bottom, AppTheme.paddingXL)

                Text("Your workouts are always saved locally.\nSign in to enable cloud sync.")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textMuted.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    SignInView()
        .environment(AppState())
}
