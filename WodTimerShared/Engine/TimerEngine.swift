import Foundation
import Combine

// MARK: - Timer State

public enum TimerState: Equatable {
    case idle
    case countdown(remaining: Int)
    case running
    case paused
    case completed
}

public enum TimerPhase: Equatable {
    case work
    case rest
    case transition
}

// MARK: - Timer Engine Protocol

public protocol TimerEngineDelegate: AnyObject {
    func timerDidTick(elapsed: TimeInterval, remaining: TimeInterval)
    func timerPhaseDidChange(phase: TimerPhase, round: Int, set: Int)
    func timerDidComplete()
    func timerShouldPlaySound(type: SoundType)
}

public enum SoundType {
    case countdownBeep
    case countdownFinal
    case roundStart
    case roundEnd
    case workStart
    case restStart
    case complete
    case intervalSignal
}

// MARK: - Base Timer Engine

@Observable
public class TimerEngine {
    public var state: TimerState = .idle
    public var phase: TimerPhase = .work
    public var elapsedSeconds: TimeInterval = 0
    public var remainingSeconds: TimeInterval = 0
    public var currentRound: Int = 1
    public var currentSet: Int = 1
    public var totalRounds: Int = 1
    public var totalSets: Int = 1

    public var displayTime: String {
        let seconds = state == .idle ? remainingSeconds : remainingSeconds
        return TimeFormatter.mmss(max(0, Int(seconds)))
    }

    public var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return min(1.0, elapsedSeconds / totalDuration)
    }

    public weak var delegate: TimerEngineDelegate?

    private var timer: Timer?
    private var lastTickDate: Date?
    public var totalDuration: TimeInterval = 0

    public init() {}

    // MARK: - Controls

    public func start() {
        guard state == .idle || state == .paused else { return }

        if state == .idle {
            beginCountdown()
        } else {
            resume()
        }
    }

    public func pause() {
        guard state == .running else { return }
        state = .paused
        stopTimer()
    }

    public func reset() {
        stopTimer()
        state = .idle
        elapsedSeconds = 0
        currentRound = 1
        currentSet = 1
        phase = .work
        onReset()
    }

    public func stop() {
        stopTimer()
        state = .completed
        delegate?.timerDidComplete()
        delegate?.timerShouldPlaySound(type: .complete)
    }

    // MARK: - Countdown

    private func beginCountdown() {
        var count = AppConstants.countdownSeconds
        state = .countdown(remaining: count)
        delegate?.timerShouldPlaySound(type: .countdownBeep)

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            count -= 1
            if count > 0 {
                self.state = .countdown(remaining: count)
                self.delegate?.timerShouldPlaySound(type: .countdownBeep)
            } else {
                self.stopTimer()
                self.delegate?.timerShouldPlaySound(type: .countdownFinal)
                self.beginRunning()
            }
        }
    }

    private func beginRunning() {
        state = .running
        lastTickDate = Date()
        onStart()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func resume() {
        state = .running
        lastTickDate = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard state == .running, let lastTick = lastTickDate else { return }

        let now = Date()
        let delta = now.timeIntervalSince(lastTick)
        lastTickDate = now
        elapsedSeconds += delta

        onTick(delta: delta)

        delegate?.timerDidTick(elapsed: elapsedSeconds, remaining: remainingSeconds)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        lastTickDate = nil
    }

    // MARK: - Subclass Hooks

    open func onStart() {
        // Override in subclasses
    }

    open func onTick(delta: TimeInterval) {
        remainingSeconds = max(0, totalDuration - elapsedSeconds)
        if remainingSeconds <= 0 {
            stop()
        }
    }

    open func onReset() {
        remainingSeconds = totalDuration
    }
}
