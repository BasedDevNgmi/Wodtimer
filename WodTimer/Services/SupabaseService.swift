import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    static var isConfigured: Bool {
        AppConstants.supabaseURL != "YOUR_SUPABASE_URL" &&
        AppConstants.supabaseAnonKey != "YOUR_SUPABASE_ANON_KEY"
    }

    private init() {
        let url: String
        let key: String
        if Self.isConfigured {
            url = AppConstants.supabaseURL
            key = AppConstants.supabaseAnonKey
        } else {
            url = "https://placeholder.supabase.co"
            key = "placeholder"
        }
        client = SupabaseClient(
            supabaseURL: URL(string: url)!,
            supabaseKey: key
        )
    }

    // MARK: - Workout Sessions

    func uploadWorkout(_ session: WorkoutSession) async throws {
        let dto = WorkoutSessionDTO(
            id: session.id.uuidString,
            timerType: session.timerTypeRaw,
            configData: session.configData.base64EncodedString(),
            startedAt: session.startedAt.ISO8601Format(),
            completedAt: session.completedAt?.ISO8601Format(),
            duration: session.duration,
            notes: session.notes,
            roundsCompleted: session.roundsCompleted,
            updatedAt: session.updatedAt.ISO8601Format()
        )

        try await client
            .from("workout_sessions")
            .upsert(dto)
            .execute()
    }

    func fetchWorkouts(since: Date?) async throws -> [WorkoutSessionDTO] {
        var query = client
            .from("workout_sessions")
            .select()

        if let since {
            query = query.gt("updated_at", value: since.ISO8601Format())
        }

        return try await query
            .order("started_at", ascending: false)
            .execute()
            .value
    }

    // MARK: - Presets

    func uploadPreset(_ preset: Preset) async throws {
        let dto = PresetDTO(
            id: preset.id.uuidString,
            name: preset.name,
            timerType: preset.timerTypeRaw,
            configData: preset.configData.base64EncodedString(),
            createdAt: preset.createdAt.ISO8601Format(),
            updatedAt: preset.updatedAt.ISO8601Format()
        )

        try await client
            .from("presets")
            .upsert(dto)
            .execute()
    }

    func fetchPresets(since: Date?) async throws -> [PresetDTO] {
        var query = client
            .from("presets")
            .select()

        if let since {
            query = query.gt("updated_at", value: since.ISO8601Format())
        }

        return try await query
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    // MARK: - Profile

    func updatePremiumStatus(_ isPremium: Bool) async throws {
        guard let userId = client.auth.currentUser?.id else { return }

        try await client
            .from("profiles")
            .update(["is_premium": isPremium, "updated_at": Date().ISO8601Format()])
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
}

// MARK: - DTOs

struct WorkoutSessionDTO: Codable {
    let id: String
    let timerType: String
    let configData: String
    let startedAt: String
    let completedAt: String?
    let duration: TimeInterval
    let notes: String
    let roundsCompleted: Int?
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case timerType = "timer_type"
        case configData = "config_data"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case duration
        case notes
        case roundsCompleted = "rounds_completed"
        case updatedAt = "updated_at"
    }
}

struct PresetDTO: Codable {
    let id: String
    let name: String
    let timerType: String
    let configData: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case timerType = "timer_type"
        case configData = "config_data"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
