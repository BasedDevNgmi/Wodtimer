import Foundation

@Observable
public final class EMOMEngine: TimerEngine {
    public var config: EMOMConfig
    private var roundElapsed: TimeInterval = 0

    public var roundRemainingSeconds: TimeInterval {
        max(0, TimeInterval(config.everyMinutes * 60) - roundElapsed)
    }

    public var roundDisplayTime: String {
        TimeFormatter.mmss(Int(roundRemainingSeconds))
    }

    public var roundProgress: Double {
        let roundDuration = TimeInterval(config.everyMinutes * 60)
        guard roundDuration > 0 else { return 0 }
        return min(1.0, roundElapsed / roundDuration)
    }

    public init(config: EMOMConfig = EMOMConfig()) {
        self.config = config
        super.init()
        configure()
    }

    public func configure() {
        totalDuration = TimeInterval(config.totalDurationSeconds)
        remainingSeconds = totalDuration
        totalRounds = config.totalRounds
        totalSets = config.sets
        currentRound = 1
        currentSet = 1
        roundElapsed = 0
    }

    override public func onStart() {
        configure()
        delegate?.timerPhaseDidChange(phase: .work, round: 1, set: 1)
        delegate?.timerShouldPlaySound(type: .roundStart)
    }

    override public func onTick(delta: TimeInterval) {
        roundElapsed += delta
        remainingSeconds = max(0, totalDuration - elapsedSeconds)

        let roundDuration = TimeInterval(config.everyMinutes * 60)

        // Countdown warning at 3 seconds before round end
        if roundRemainingSeconds <= 3 && roundRemainingSeconds > 2 {
            delegate?.timerShouldPlaySound(type: .countdownBeep)
        }

        // Round transition
        if roundElapsed >= roundDuration {
            advanceRound()
        }

        // Total completion
        if remainingSeconds <= 0 {
            stop()
        }
    }

    override public func onReset() {
        configure()
    }

    private func advanceRound() {
        let roundsPerSet = config.forMinutes / config.everyMinutes
        let roundInSet = (currentRound - 1) % roundsPerSet + 1

        if roundInSet >= roundsPerSet {
            // End of set
            if currentSet < totalSets {
                currentSet += 1
                currentRound += 1
                roundElapsed = 0
                delegate?.timerPhaseDidChange(phase: .work, round: currentRound, set: currentSet)
                delegate?.timerShouldPlaySound(type: .roundStart)
            } else {
                stop()
                return
            }
        } else {
            currentRound += 1
            roundElapsed = 0
            delegate?.timerPhaseDidChange(phase: .work, round: currentRound, set: currentSet)
            delegate?.timerShouldPlaySound(type: .roundStart)
        }
    }
}
