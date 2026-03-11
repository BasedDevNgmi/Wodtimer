import Foundation
import SwiftData
import SwiftUI

@Observable
final class DataService {
    static let shared = DataService()

    private init() {}

    // MARK: - Workout Sessions

    func saveWorkout(
        timerType: TimerType,
        configData: Data,
        startedAt: Date,
        duration: TimeInterval,
        notes: String,
        roundsCompleted: Int?,
        in context: ModelContext
    ) -> WorkoutSession {
        let session = WorkoutSession(
            timerType: timerType,
            configData: configData,
            startedAt: startedAt,
            completedAt: Date(),
            duration: duration,
            notes: notes,
            roundsCompleted: roundsCompleted
        )
        context.insert(session)
        try? context.save()
        return session
    }

    func fetchWorkouts(in context: ModelContext) -> [WorkoutSession] {
        let descriptor = FetchDescriptor<WorkoutSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func deleteWorkout(_ session: WorkoutSession, in context: ModelContext) {
        context.delete(session)
        try? context.save()
    }

    // MARK: - Presets

    func savePreset(
        name: String,
        timerType: TimerType,
        configData: Data,
        in context: ModelContext
    ) -> Preset {
        let preset = Preset(
            name: name,
            timerType: timerType,
            configData: configData
        )
        context.insert(preset)
        try? context.save()
        return preset
    }

    func fetchPresets(for timerType: TimerType? = nil, in context: ModelContext) -> [Preset] {
        var descriptor = FetchDescriptor<Preset>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        if let timerType {
            descriptor.predicate = #Predicate<Preset> { preset in
                preset.timerTypeRaw == timerType.rawValue
            }
        }
        return (try? context.fetch(descriptor)) ?? []
    }

    func deletePreset(_ preset: Preset, in context: ModelContext) {
        context.delete(preset)
        try? context.save()
    }

    // MARK: - Sync Helpers

    func fetchUnsyncedWorkouts(in context: ModelContext) -> [WorkoutSession] {
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate<WorkoutSession> { $0.synced == false }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchUnsyncedPresets(in context: ModelContext) -> [Preset] {
        let descriptor = FetchDescriptor<Preset>(
            predicate: #Predicate<Preset> { $0.synced == false }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func markSynced(_ session: WorkoutSession, in context: ModelContext) {
        session.synced = true
        session.updatedAt = Date()
        try? context.save()
    }

    func markSynced(_ preset: Preset, in context: ModelContext) {
        preset.synced = true
        preset.updatedAt = Date()
        try? context.save()
    }
}
