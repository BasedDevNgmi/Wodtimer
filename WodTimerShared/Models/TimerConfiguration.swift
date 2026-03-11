import Foundation

// MARK: - Protocol

public protocol TimerConfiguration: Codable, Equatable {
    var timerType: TimerType { get }
    var totalDurationSeconds: Int { get }
}

// MARK: - AMRAP

public struct AMRAPSegment: Codable, Equatable, Identifiable {
    public var id = UUID()
    public var minutes: Int

    public init(minutes: Int = 10) {
        self.minutes = minutes
    }
}

public struct AMRAPConfig: TimerConfiguration {
    public var timerType: TimerType { .amrap }
    public var segments: [AMRAPSegment]

    public var totalDurationSeconds: Int {
        segments.reduce(0) { $0 + $1.minutes * 60 }
    }

    public var minutes: Int {
        get { segments.first?.minutes ?? 10 }
        set {
            if segments.isEmpty {
                segments = [AMRAPSegment(minutes: newValue)]
            } else {
                segments[0].minutes = newValue
            }
        }
    }

    public init(minutes: Int = 10) {
        self.segments = [AMRAPSegment(minutes: minutes)]
    }

    public init(segments: [AMRAPSegment]) {
        self.segments = segments.isEmpty ? [AMRAPSegment()] : segments
    }
}

// MARK: - For Time

public struct ForTimeConfig: TimerConfiguration {
    public var timerType: TimerType { .forTime }
    public var timeCapMinutes: Int
    public var sets: Int
    public var intervalSignalMinutes: Int?

    public var totalDurationSeconds: Int {
        timeCapMinutes * 60 * sets
    }

    public init(timeCapMinutes: Int = 12, sets: Int = 1, intervalSignalMinutes: Int? = nil) {
        self.timeCapMinutes = timeCapMinutes
        self.sets = sets
        self.intervalSignalMinutes = intervalSignalMinutes
    }
}

// MARK: - EMOM

public struct EMOMConfig: TimerConfiguration {
    public var timerType: TimerType { .emom }
    public var everyMinutes: Int
    public var forMinutes: Int
    public var sets: Int
    public var deathBy: Bool

    public var totalDurationSeconds: Int {
        forMinutes * 60 * sets
    }

    public var totalRounds: Int {
        (forMinutes / everyMinutes) * sets
    }

    public init(everyMinutes: Int = 1, forMinutes: Int = 30, sets: Int = 1, deathBy: Bool = false) {
        self.everyMinutes = everyMinutes
        self.forMinutes = forMinutes
        self.sets = sets
        self.deathBy = deathBy
    }
}

// MARK: - Tabata

public struct TabataConfig: TimerConfiguration {
    public var timerType: TimerType { .tabata }
    public var rounds: Int
    public var workSeconds: Int
    public var restSeconds: Int
    public var sets: Int

    public var totalDurationSeconds: Int {
        (workSeconds + restSeconds) * rounds * sets
    }

    public init(rounds: Int = 3, workSeconds: Int = 120, restSeconds: Int = 120, sets: Int = 1) {
        self.rounds = rounds
        self.workSeconds = workSeconds
        self.restSeconds = restSeconds
        self.sets = sets
    }
}

// MARK: - Mix

public struct MixSegment: Codable, Equatable, Identifiable {
    public var id = UUID()
    public var timerType: TimerType
    public var configData: Data

    public init(timerType: TimerType, configData: Data) {
        self.timerType = timerType
        self.configData = configData
    }
}

public struct MixConfig: TimerConfiguration {
    public var timerType: TimerType { .mix }
    public var segments: [MixSegment]

    public var totalDurationSeconds: Int {
        // Estimated; actual depends on decoded configs
        0
    }

    public init(segments: [MixSegment] = []) {
        self.segments = segments
    }
}

// MARK: - Wrapper for encoding any config

public struct AnyTimerConfig: Codable, Equatable {
    public let type: TimerType
    public let data: Data

    public init<T: TimerConfiguration>(_ config: T) throws {
        self.type = config.timerType
        self.data = try JSONEncoder().encode(config)
    }

    public func decode() throws -> any TimerConfiguration {
        let decoder = JSONDecoder()
        switch type {
        case .amrap: return try decoder.decode(AMRAPConfig.self, from: data)
        case .forTime: return try decoder.decode(ForTimeConfig.self, from: data)
        case .emom: return try decoder.decode(EMOMConfig.self, from: data)
        case .tabata: return try decoder.decode(TabataConfig.self, from: data)
        case .mix: return try decoder.decode(MixConfig.self, from: data)
        }
    }
}
