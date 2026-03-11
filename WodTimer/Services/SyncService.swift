import Foundation
import SwiftData

@Observable
final class SyncService {
    static let shared = SyncService()

    var isSyncing: Bool = false
    var lastSyncDate: Date?
    var syncError: String?

    private let supabase = SupabaseService.shared
    private let lastSyncKey = "lastSyncDate"

    private init() {
        lastSyncDate = UserDefaults.standard.object(forKey: lastSyncKey) as? Date
    }

    // MARK: - Full Sync

    func sync(context: ModelContext) async {
        guard AuthService.shared.isAuthenticated else { return }
        guard !isSyncing else { return }

        isSyncing = true
        syncError = nil

        do {
            try await pushWorkouts(context: context)
            try await pushPresets(context: context)
            try await pullWorkouts(context: context)
            try await pullPresets(context: context)

            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: lastSyncKey)
        } catch {
            syncError = error.localizedDescription
        }

        isSyncing = false
    }

    // MARK: - Push

    private func pushWorkouts(context: ModelContext) async throws {
        let unsynced = DataService.shared.fetchUnsyncedWorkouts(in: context)
        for session in unsynced {
            try await supabase.uploadWorkout(session)
            DataService.shared.markSynced(session, in: context)
        }
    }

    private func pushPresets(context: ModelContext) async throws {
        let unsynced = DataService.shared.fetchUnsyncedPresets(in: context)
        for preset in unsynced {
            try await supabase.uploadPreset(preset)
            DataService.shared.markSynced(preset, in: context)
        }
    }

    // MARK: - Pull

    private func pullWorkouts(context: ModelContext) async throws {
        let remoteDTOs = try await supabase.fetchWorkouts(since: lastSyncDate)
        let localWorkouts = DataService.shared.fetchWorkouts(in: context)
        let localIds = Set(localWorkouts.map { $0.id.uuidString })

        for dto in remoteDTOs {
            guard !localIds.contains(dto.id) else {
                // Update existing if remote is newer (last-write-wins)
                if let local = localWorkouts.first(where: { $0.id.uuidString == dto.id }) {
                    let remoteDate = ISO8601DateFormatter().date(from: dto.updatedAt) ?? Date.distantPast
                    if remoteDate > local.updatedAt {
                        updateWorkout(local, from: dto)
                    }
                }
                continue
            }

            // Insert new
            let session = workoutFromDTO(dto)
            context.insert(session)
        }
        try? context.save()
    }

    private func pullPresets(context: ModelContext) async throws {
        let remoteDTOs = try await supabase.fetchPresets(since: lastSyncDate)
        let localPresets = DataService.shared.fetchPresets(in: context)
        let localIds = Set(localPresets.map { $0.id.uuidString })

        for dto in remoteDTOs {
            guard !localIds.contains(dto.id) else { continue }

            let preset = presetFromDTO(dto)
            context.insert(preset)
        }
        try? context.save()
    }

    // MARK: - DTO Conversion

    private func workoutFromDTO(_ dto: WorkoutSessionDTO) -> WorkoutSession {
        let formatter = ISO8601DateFormatter()
        return WorkoutSession(
            id: UUID(uuidString: dto.id) ?? UUID(),
            timerType: TimerType(rawValue: dto.timerType) ?? .amrap,
            configData: Data(base64Encoded: dto.configData) ?? Data(),
            startedAt: formatter.date(from: dto.startedAt) ?? Date(),
            completedAt: dto.completedAt.flatMap { formatter.date(from: $0) },
            duration: dto.duration,
            notes: dto.notes,
            roundsCompleted: dto.roundsCompleted,
            synced: true
        )
    }

    private func updateWorkout(_ local: WorkoutSession, from dto: WorkoutSessionDTO) {
        local.notes = dto.notes
        local.roundsCompleted = dto.roundsCompleted
        local.synced = true
        local.updatedAt = Date()
    }

    private func presetFromDTO(_ dto: PresetDTO) -> Preset {
        Preset(
            id: UUID(uuidString: dto.id) ?? UUID(),
            name: dto.name,
            timerType: TimerType(rawValue: dto.timerType) ?? .amrap,
            configData: Data(base64Encoded: dto.configData) ?? Data(),
            synced: true
        )
    }
}
