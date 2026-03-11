import Foundation
#if os(iOS)
import UIKit
#endif
#if os(watchOS)
import WatchKit
#endif

public final class HapticManager {
    public static let shared = HapticManager()

    private init() {}

    public func play(_ type: HapticType) {
        #if os(iOS)
        playiOS(type)
        #elseif os(watchOS)
        playWatchOS(type)
        #endif
    }

    #if os(iOS)
    private func playiOS(_ type: HapticType) {
        switch type {
        case .countdownTick:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .phaseChange:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .roundComplete:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .workoutComplete:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
    #endif

    #if os(watchOS)
    private func playWatchOS(_ type: HapticType) {
        switch type {
        case .countdownTick:
            WKInterfaceDevice.current().play(.click)
        case .phaseChange:
            WKInterfaceDevice.current().play(.directionUp)
        case .roundComplete:
            WKInterfaceDevice.current().play(.success)
        case .workoutComplete:
            WKInterfaceDevice.current().play(.success)
        case .warning:
            WKInterfaceDevice.current().play(.retry)
        }
    }
    #endif
}

public enum HapticType {
    case countdownTick
    case phaseChange
    case roundComplete
    case workoutComplete
    case warning
}
