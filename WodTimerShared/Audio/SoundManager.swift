import AVFoundation
import Foundation

@Observable
public final class SoundManager {
    public static let shared = SoundManager()

    public var isMuted: Bool = false
    private var audioPlayer: AVAudioPlayer?

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        #endif
    }

    public func play(_ type: SoundType) {
        guard !isMuted else { return }

        switch type {
        case .countdownBeep:
            playSystemSound(id: 1057)
        case .countdownFinal:
            playSystemSound(id: 1304)
        case .roundStart, .workStart:
            playSystemSound(id: 1304)
        case .roundEnd, .restStart:
            playSystemSound(id: 1305)
        case .complete:
            playSystemSound(id: 1025)
        case .intervalSignal:
            playSystemSound(id: 1057)
        }
    }

    private func playSystemSound(id: UInt32) {
        #if os(iOS) || os(watchOS)
        AudioServicesPlaySystemSound(SystemSoundID(id))
        #endif
    }
}
