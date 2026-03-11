import SwiftUI

public enum TimerType: String, Codable, CaseIterable, Identifiable {
    case amrap
    case forTime
    case emom
    case tabata
    case mix

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .amrap: return "AMRAP"
        case .forTime: return "FOR TIME"
        case .emom: return "EMOM"
        case .tabata: return "TABATA"
        case .mix: return "MIX"
        }
    }

    public var subtitle: String {
        switch self {
        case .amrap: return "As many rounds as possible"
        case .forTime: return "As fast as possible for time"
        case .emom: return "Every minute on a minute"
        case .tabata: return "Work / Rest intervals"
        case .mix: return "Combine multiple timers"
        }
    }

    public var color: Color {
        switch self {
        case .amrap: return Color(hex: "F5A623")
        case .forTime: return Color(hex: "7B8CDE")
        case .emom: return Color(hex: "A855F7")
        case .tabata: return Color(hex: "34D399")
        case .mix: return Color(hex: "6B7280")
        }
    }

    public var isPremium: Bool {
        self == .mix
    }
}
