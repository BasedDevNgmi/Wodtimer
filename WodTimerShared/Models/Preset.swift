import Foundation
import SwiftData

@Model
public class Preset {
    public var id: UUID
    public var name: String
    public var timerTypeRaw: String
    public var configData: Data
    public var createdAt: Date
    public var synced: Bool
    public var updatedAt: Date

    public var timerType: TimerType {
        get { TimerType(rawValue: timerTypeRaw) ?? .amrap }
        set { timerTypeRaw = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        name: String,
        timerType: TimerType,
        configData: Data,
        createdAt: Date = Date(),
        synced: Bool = false
    ) {
        self.id = id
        self.name = name
        self.timerTypeRaw = timerType.rawValue
        self.configData = configData
        self.createdAt = createdAt
        self.synced = synced
        self.updatedAt = Date()
    }
}
