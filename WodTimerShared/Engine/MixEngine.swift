import Foundation

@Observable
public final class MixEngine: TimerEngine {
    public var config: MixConfig
    public var currentSegmentIndex: Int = 0
    public var segmentEngines: [TimerEngine] = []
    private var currentSubEngine: TimerEngine?

    public var currentSegmentName: String {
        guard currentSegmentIndex < config.segments.count else { return "" }
        return config.segments[currentSegmentIndex].timerType.displayName
    }

    public var segmentProgress: Double {
        guard config.segments.count > 0 else { return 0 }
        return Double(currentSegmentIndex) / Double(config.segments.count)
    }

    public init(config: MixConfig = MixConfig()) {
        self.config = config
        super.init()
        buildSegmentEngines()
    }

    public func buildSegmentEngines() {
        segmentEngines = config.segments.compactMap { segment in
            let decoder = JSONDecoder()
            switch segment.timerType {
            case .amrap:
                if let cfg = try? decoder.decode(AMRAPConfig.self, from: segment.configData) {
                    return AMRAPEngine(config: cfg)
                }
            case .forTime:
                if let cfg = try? decoder.decode(ForTimeConfig.self, from: segment.configData) {
                    return ForTimeEngine(config: cfg)
                }
            case .emom:
                if let cfg = try? decoder.decode(EMOMConfig.self, from: segment.configData) {
                    return EMOMEngine(config: cfg)
                }
            case .tabata:
                if let cfg = try? decoder.decode(TabataConfig.self, from: segment.configData) {
                    return TabataEngine(config: cfg)
                }
            case .mix:
                return nil // No nested mix
            }
            return nil
        }

        totalDuration = segmentEngines.reduce(0) { $0 + $1.totalDuration }
        remainingSeconds = totalDuration
        totalRounds = segmentEngines.count
        currentSegmentIndex = 0
    }

    override public func onStart() {
        buildSegmentEngines()
        startCurrentSegment()
    }

    override public func onTick(delta: TimeInterval) {
        remainingSeconds = max(0, totalDuration - elapsedSeconds)

        guard currentSegmentIndex < segmentEngines.count else {
            stop()
            return
        }

        let engine = segmentEngines[currentSegmentIndex]

        // Check if current segment is complete
        if engine.state == .completed {
            currentSegmentIndex += 1
            if currentSegmentIndex < segmentEngines.count {
                currentRound = currentSegmentIndex + 1
                startCurrentSegment()
            } else {
                stop()
            }
        }
    }

    override public func onReset() {
        currentSegmentIndex = 0
        segmentEngines.forEach { $0.reset() }
        buildSegmentEngines()
    }

    private func startCurrentSegment() {
        guard currentSegmentIndex < segmentEngines.count else { return }
        let engine = segmentEngines[currentSegmentIndex]
        engine.delegate = delegate
        engine.start()
        delegate?.timerPhaseDidChange(phase: .work, round: currentSegmentIndex + 1, set: 1)
        delegate?.timerShouldPlaySound(type: .roundStart)
    }
}
