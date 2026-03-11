import Foundation
import SwiftData

@Model
public class WorkoutSession {
    public var id: UUID
    public var timerTypeRaw: String
    public var configData: Data
    public var startedAt: Date
    public var completedAt: Date?
    public var duration: TimeInterval
    public var notes: String
    public var roundsCompleted: Int?
    public var synced: Bool
    public var updatedAt: Date

    public var timerType: TimerType {
        get { TimerType(rawValue: timerTypeRaw) ?? .amrap }
        set { timerTypeRaw = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        timerType: TimerType,
        configData: Data,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        duration: TimeInterval = 0,
        notes: String = "",
        roundsCompleted: Int? = nil,
        synced: Bool = false
    ) {
        self.id = id
        self.timerTypeRaw = timerType.rawValue
        self.configData = configData
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.duration = duration
        self.notes = notes
        self.roundsCompleted = roundsCompleted
        self.synced = synced
        self.updatedAt = Date()
    }
}
