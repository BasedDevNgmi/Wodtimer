import Foundation

@Observable
public final class AMRAPEngine: TimerEngine {
    public var config: AMRAPConfig
    public var currentSegmentIndex: Int = 0
    private var segmentElapsed: TimeInterval = 0

    public var currentSegment: AMRAPSegment? {
        guard currentSegmentIndex < config.segments.count else { return nil }
        return config.segments[currentSegmentIndex]
    }

    public var segmentRemainingSeconds: TimeInterval {
        guard let segment = currentSegment else { return 0 }
        return max(0, TimeInterval(segment.minutes * 60) - segmentElapsed)
    }

    public var segmentDisplayTime: String {
        TimeFormatter.mmss(max(0, Int(segmentRemainingSeconds)))
    }

    public var isMultiSegment: Bool {
        config.segments.count > 1
    }

    public init(config: AMRAPConfig = AMRAPConfig()) {
        self.config = config
        super.init()
        configure()
    }

    public func configure() {
        totalDuration = TimeInterval(config.totalDurationSeconds)
        remainingSeconds = totalDuration
        totalRounds = config.segments.count
        currentSegmentIndex = 0
        segmentElapsed = 0
    }

    override public func onStart() {
        configure()
        delegate?.timerPhaseDidChange(phase: .work, round: 1, set: 1)
        delegate?.timerShouldPlaySound(type: .roundStart)
    }

    override public func onTick(delta: TimeInterval) {
        segmentElapsed += delta
        remainingSeconds = max(0, totalDuration - elapsedSeconds)

        // Check segment transition for multi-AMRAP
        if isMultiSegment, let segment = currentSegment {
            if segmentElapsed >= TimeInterval(segment.minutes * 60) {
                advanceSegment()
            }
        }

        // Check total completion
        if remainingSeconds <= 0 {
            stop()
        }

        // Countdown warning at 3 seconds
        if segmentRemainingSeconds <= 3 && segmentRemainingSeconds > 2 {
            delegate?.timerShouldPlaySound(type: .countdownBeep)
        }
    }

    override public func onReset() {
        configure()
    }

    private func advanceSegment() {
        currentSegmentIndex += 1
        segmentElapsed = 0

        if currentSegmentIndex < config.segments.count {
            currentRound = currentSegmentIndex + 1
            delegate?.timerPhaseDidChange(phase: .work, round: currentRound, set: 1)
            delegate?.timerShouldPlaySound(type: .roundStart)
        }
    }
}
