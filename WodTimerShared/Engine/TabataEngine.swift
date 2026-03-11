import Foundation

@Observable
public final class TabataEngine: TimerEngine {
    public var config: TabataConfig
    private var phaseElapsed: TimeInterval = 0

    public var phaseRemainingSeconds: TimeInterval {
        let phaseDuration = phase == .work
            ? TimeInterval(config.workSeconds)
            : TimeInterval(config.restSeconds)
        return max(0, phaseDuration - phaseElapsed)
    }

    public var phaseDisplayTime: String {
        TimeFormatter.mmss(Int(phaseRemainingSeconds))
    }

    public var phaseProgress: Double {
        let phaseDuration = phase == .work
            ? TimeInterval(config.workSeconds)
            : TimeInterval(config.restSeconds)
        guard phaseDuration > 0 else { return 0 }
        return min(1.0, phaseElapsed / phaseDuration)
    }

    public var isWorkPhase: Bool { phase == .work }

    public init(config: TabataConfig = TabataConfig()) {
        self.config = config
        super.init()
        configure()
    }

    public func configure() {
        totalDuration = TimeInterval(config.totalDurationSeconds)
        remainingSeconds = totalDuration
        totalRounds = config.rounds
        totalSets = config.sets
        currentRound = 1
        currentSet = 1
        phase = .work
        phaseElapsed = 0
    }

    override public func onStart() {
        configure()
        delegate?.timerPhaseDidChange(phase: .work, round: 1, set: 1)
        delegate?.timerShouldPlaySound(type: .workStart)
    }

    override public func onTick(delta: TimeInterval) {
        phaseElapsed += delta
        remainingSeconds = max(0, totalDuration - elapsedSeconds)

        let currentPhaseDuration = phase == .work
            ? TimeInterval(config.workSeconds)
            : TimeInterval(config.restSeconds)

        // Countdown warning
        if phaseRemainingSeconds <= 3 && phaseRemainingSeconds > 2 {
            delegate?.timerShouldPlaySound(type: .countdownBeep)
        }

        // Phase transition
        if phaseElapsed >= currentPhaseDuration {
            advancePhase()
        }

        // Total completion
        if remainingSeconds <= 0 {
            stop()
        }
    }

    override public func onReset() {
        configure()
    }

    private func advancePhase() {
        phaseElapsed = 0

        if phase == .work {
            // Switch to rest
            phase = .rest
            delegate?.timerPhaseDidChange(phase: .rest, round: currentRound, set: currentSet)
            delegate?.timerShouldPlaySound(type: .restStart)
        } else {
            // Rest done, advance round
            if currentRound < totalRounds {
                currentRound += 1
                phase = .work
                delegate?.timerPhaseDidChange(phase: .work, round: currentRound, set: currentSet)
                delegate?.timerShouldPlaySound(type: .workStart)
            } else if currentSet < totalSets {
                // Next set
                currentSet += 1
                currentRound = 1
                phase = .work
                delegate?.timerPhaseDidChange(phase: .work, round: 1, set: currentSet)
                delegate?.timerShouldPlaySound(type: .workStart)
            } else {
                stop()
            }
        }
    }
}
