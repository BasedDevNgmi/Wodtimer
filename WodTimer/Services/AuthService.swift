import Foundation
import AuthenticationServices
import Supabase

@Observable
final class AuthService {
    static let shared = AuthService()

    var isAuthenticated: Bool = false
    var currentUser: UserProfile?
    var isLoading: Bool = false
    var error: String?

    private let supabase = SupabaseService.shared

    private init() {
        Task {
            await checkExistingSession()
        }
    }

    // MARK: - Apple Sign In

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async {
        isLoading = true
        error = nil

        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            error = "Invalid Apple ID credential"
            isLoading = false
            return
        }

        do {
            let session = try await supabase.client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: tokenString
                )
            )

            let user = session.user
            currentUser = UserProfile(
                id: user.id,
                appleUserId: credential.user,
                displayName: buildDisplayName(from: credential)
            )

            // Ensure profile exists in Supabase
            try await ensureProfile(userId: user.id, displayName: currentUser?.displayName)

            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() async {
        do {
            try await supabase.client.auth.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Session Management

    private func checkExistingSession() async {
        do {
            let session = try await supabase.client.auth.session
            let user = session.user
            currentUser = UserProfile(
                id: user.id,
                appleUserId: user.id.uuidString,
                displayName: user.userMetadata["full_name"]?.value as? String
            )
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }

    private func ensureProfile(userId: UUID, displayName: String?) async throws {
        let profile: [String: Any] = [
            "user_id": userId.uuidString,
            "display_name": displayName ?? "",
            "is_premium": false,
            "updated_at": Date().ISO8601Format()
        ]

        try await supabase.client
            .from("profiles")
            .upsert(profile)
            .execute()
    }

    private func buildDisplayName(from credential: ASAuthorizationAppleIDCredential) -> String? {
        let firstName = credential.fullName?.givenName
        let lastName = credential.fullName?.familyName

        if let firstName, let lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName {
            return firstName
        }
        return nil
    }
}
