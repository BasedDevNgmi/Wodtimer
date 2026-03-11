import Foundation

@Observable
public final class ForTimeEngine: TimerEngine {
    public var config: ForTimeConfig
    private var setElapsed: TimeInterval = 0
    private var lastIntervalSignal: Int = 0

    /// For Time counts UP, so display the elapsed time
    public var elapsedDisplayTime: String {
        TimeFormatter.mmss(Int(setElapsed))
    }

    /// Time cap remaining
    public var timeCapRemaining: TimeInterval {
        max(0, TimeInterval(config.timeCapMinutes * 60) - setElapsed)
    }

    public init(config: ForTimeConfig = ForTimeConfig()) {
        self.config = config
        super.init()
        configure()
    }

    public func configure() {
        totalDuration = TimeInterval(config.totalDurationSeconds)
        remainingSeconds = totalDuration
        totalSets = config.sets
        currentSet = 1
        setElapsed = 0
        lastIntervalSignal = 0
    }

    override public func onStart() {
        configure()
        delegate?.timerPhaseDidChange(phase: .work, round: 1, set: 1)
        delegate?.timerShouldPlaySound(type: .roundStart)
    }

    override public func onTick(delta: TimeInterval) {
        setElapsed += delta
        remainingSeconds = max(0, totalDuration - elapsedSeconds)

        // Interval signal
        if let interval = config.intervalSignalMinutes, interval > 0 {
            let currentMinute = Int(setElapsed) / 60
            if currentMinute > lastIntervalSignal && currentMinute % interval == 0 {
                lastIntervalSignal = currentMinute
                delegate?.timerShouldPlaySound(type: .intervalSignal)
            }
        }

        // Check if current set time cap reached
        let setTimeCap = TimeInterval(config.timeCapMinutes * 60)
        if setElapsed >= setTimeCap {
            advanceSet()
        }

        // Total completion
        if remainingSeconds <= 0 {
            stop()
        }
    }

    override public func onReset() {
        configure()
    }

    /// User manually marks "done" before time cap
    public func markComplete() {
        if currentSet < totalSets {
            advanceSet()
        } else {
            stop()
        }
    }

    private func advanceSet() {
        if currentSet < totalSets {
            currentSet += 1
            setElapsed = 0
            lastIntervalSignal = 0
            delegate?.timerPhaseDidChange(phase: .work, round: 1, set: currentSet)
            delegate?.timerShouldPlaySound(type: .roundStart)
        } else {
            stop()
        }
    }
}
