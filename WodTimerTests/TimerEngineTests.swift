import XCTest
@testable import WodTimerShared

final class TimerEngineTests: XCTestCase {

    // MARK: - AMRAP Engine Tests

    func testAMRAPEngineInitialization() {
        let config = AMRAPConfig(minutes: 10)
        let engine = AMRAPEngine(config: config)

        XCTAssertEqual(engine.totalDuration, 600)
        XCTAssertEqual(engine.remainingSeconds, 600)
        XCTAssertEqual(engine.state, .idle)
        XCTAssertEqual(engine.currentRound, 1)
    }

    func testAMRAPMultiSegment() {
        let segments = [AMRAPSegment(minutes: 5), AMRAPSegment(minutes: 10)]
        let config = AMRAPConfig(segments: segments)
        let engine = AMRAPEngine(config: config)

        XCTAssertEqual(engine.totalDuration, 900)
        XCTAssertTrue(engine.isMultiSegment)
        XCTAssertEqual(engine.totalRounds, 2)
    }

    func testAMRAPReset() {
        let engine = AMRAPEngine(config: AMRAPConfig(minutes: 10))
        engine.elapsedSeconds = 300
        engine.remainingSeconds = 300
        engine.currentRound = 3

        engine.reset()

        XCTAssertEqual(engine.state, .idle)
        XCTAssertEqual(engine.elapsedSeconds, 0)
        XCTAssertEqual(engine.currentRound, 1)
        XCTAssertEqual(engine.remainingSeconds, 600)
    }

    // MARK: - ForTime Engine Tests

    func testForTimeEngineInitialization() {
        let config = ForTimeConfig(timeCapMinutes: 12, sets: 2)
        let engine = ForTimeEngine(config: config)

        XCTAssertEqual(engine.totalDuration, 1440)
        XCTAssertEqual(engine.totalSets, 2)
        XCTAssertEqual(engine.currentSet, 1)
    }

    func testForTimeElapsedDisplay() {
        let engine = ForTimeEngine(config: ForTimeConfig(timeCapMinutes: 12))

        XCTAssertEqual(engine.elapsedDisplayTime, "00:00")
    }

    func testForTimeReset() {
        let engine = ForTimeEngine(config: ForTimeConfig(timeCapMinutes: 12, sets: 3))
        engine.currentSet = 2
        engine.elapsedSeconds = 100

        engine.reset()

        XCTAssertEqual(engine.currentSet, 1)
        XCTAssertEqual(engine.elapsedSeconds, 0)
        XCTAssertEqual(engine.state, .idle)
    }

    // MARK: - EMOM Engine Tests

    func testEMOMEngineInitialization() {
        let config = EMOMConfig(everyMinutes: 2, forMinutes: 10, sets: 1)
        let engine = EMOMEngine(config: config)

        XCTAssertEqual(engine.totalDuration, 600)
        XCTAssertEqual(engine.totalRounds, 5)
        XCTAssertEqual(engine.currentRound, 1)
    }

    func testEMOMMultipleSets() {
        let config = EMOMConfig(everyMinutes: 1, forMinutes: 10, sets: 3)
        let engine = EMOMEngine(config: config)

        XCTAssertEqual(engine.totalDuration, 1800)
        XCTAssertEqual(engine.totalRounds, 30)
        XCTAssertEqual(engine.totalSets, 3)
    }

    func testEMOMReset() {
        let engine = EMOMEngine(config: EMOMConfig(everyMinutes: 1, forMinutes: 10))
        engine.currentRound = 5
        engine.elapsedSeconds = 240

        engine.reset()

        XCTAssertEqual(engine.currentRound, 1)
        XCTAssertEqual(engine.elapsedSeconds, 0)
        XCTAssertEqual(engine.state, .idle)
    }

    // MARK: - Tabata Engine Tests

    func testTabataEngineInitialization() {
        let config = TabataConfig(rounds: 8, workSeconds: 20, restSeconds: 10, sets: 1)
        let engine = TabataEngine(config: config)

        XCTAssertEqual(engine.totalDuration, 240)
        XCTAssertEqual(engine.totalRounds, 8)
        XCTAssertEqual(engine.phase, .work)
        XCTAssertTrue(engine.isWorkPhase)
    }

    func testTabataMultipleSets() {
        let config = TabataConfig(rounds: 3, workSeconds: 120, restSeconds: 120, sets: 2)
        let engine = TabataEngine(config: config)

        XCTAssertEqual(engine.totalDuration, 1440)
        XCTAssertEqual(engine.totalSets, 2)
    }

    func testTabataReset() {
        let engine = TabataEngine(config: TabataConfig(rounds: 8, workSeconds: 20, restSeconds: 10))
        engine.phase = .rest
        engine.currentRound = 4
        engine.elapsedSeconds = 100

        engine.reset()

        XCTAssertEqual(engine.phase, .work)
        XCTAssertEqual(engine.currentRound, 1)
        XCTAssertEqual(engine.elapsedSeconds, 0)
        XCTAssertTrue(engine.isWorkPhase)
    }

    // MARK: - Timer Configuration Tests

    func testAMRAPConfigCodable() throws {
        let config = AMRAPConfig(minutes: 15)
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(AMRAPConfig.self, from: data)

        XCTAssertEqual(decoded.minutes, 15)
        XCTAssertEqual(decoded.totalDurationSeconds, 900)
    }

    func testForTimeConfigCodable() throws {
        let config = ForTimeConfig(timeCapMinutes: 20, sets: 3, intervalSignalMinutes: 5)
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(ForTimeConfig.self, from: data)

        XCTAssertEqual(decoded.timeCapMinutes, 20)
        XCTAssertEqual(decoded.sets, 3)
        XCTAssertEqual(decoded.intervalSignalMinutes, 5)
    }

    func testEMOMConfigCodable() throws {
        let config = EMOMConfig(everyMinutes: 2, forMinutes: 20, sets: 2, deathBy: true)
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(EMOMConfig.self, from: data)

        XCTAssertEqual(decoded.everyMinutes, 2)
        XCTAssertEqual(decoded.forMinutes, 20)
        XCTAssertEqual(decoded.deathBy, true)
    }

    func testTabataConfigCodable() throws {
        let config = TabataConfig(rounds: 8, workSeconds: 20, restSeconds: 10, sets: 4)
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(TabataConfig.self, from: data)

        XCTAssertEqual(decoded.rounds, 8)
        XCTAssertEqual(decoded.workSeconds, 20)
        XCTAssertEqual(decoded.restSeconds, 10)
        XCTAssertEqual(decoded.sets, 4)
    }

    func testAnyTimerConfigWrapper() throws {
        let amrapConfig = AMRAPConfig(minutes: 10)
        let wrapper = try AnyTimerConfig(amrapConfig)

        XCTAssertEqual(wrapper.type, .amrap)

        let decoded = try wrapper.decode()
        XCTAssertEqual(decoded.timerType, .amrap)
        XCTAssertEqual(decoded.totalDurationSeconds, 600)
    }

    // MARK: - TimerType Tests

    func testTimerTypeProperties() {
        XCTAssertEqual(TimerType.amrap.displayName, "AMRAP")
        XCTAssertEqual(TimerType.forTime.displayName, "FOR TIME")
        XCTAssertEqual(TimerType.emom.displayName, "EMOM")
        XCTAssertEqual(TimerType.tabata.displayName, "TABATA")
        XCTAssertEqual(TimerType.mix.displayName, "MIX")
    }

    func testTimerTypePremium() {
        XCTAssertFalse(TimerType.amrap.isPremium)
        XCTAssertFalse(TimerType.forTime.isPremium)
        XCTAssertFalse(TimerType.emom.isPremium)
        XCTAssertFalse(TimerType.tabata.isPremium)
        XCTAssertTrue(TimerType.mix.isPremium)
    }

    // MARK: - TimeFormatter Tests

    func testTimeFormatterMMSS() {
        XCTAssertEqual(TimeFormatter.mmss(0), "00:00")
        XCTAssertEqual(TimeFormatter.mmss(61), "01:01")
        XCTAssertEqual(TimeFormatter.mmss(600), "10:00")
        XCTAssertEqual(TimeFormatter.mmss(3599), "59:59")
    }

    func testTimeFormatterAdaptive() {
        XCTAssertEqual(TimeFormatter.adaptive(600), "10:00")
        XCTAssertEqual(TimeFormatter.adaptive(3600), "1:00:00")
        XCTAssertEqual(TimeFormatter.adaptive(3661), "1:01:01")
    }

    func testTimeFormatterMinutesOnly() {
        XCTAssertEqual(TimeFormatter.minutesOnly(600), "10")
        XCTAssertEqual(TimeFormatter.minutesOnly(1800), "30")
    }

    func testTimeFormatterPrecise() {
        XCTAssertEqual(TimeFormatter.precise(61.5), "01:01.5")
        XCTAssertEqual(TimeFormatter.precise(0.0), "00:00.0")
    }

    // MARK: - Timer Engine Progress

    func testTimerEngineProgress() {
        let engine = AMRAPEngine(config: AMRAPConfig(minutes: 10))
        XCTAssertEqual(engine.progress, 0)

        engine.elapsedSeconds = 300
        XCTAssertEqual(engine.progress, 0.5, accuracy: 0.01)

        engine.elapsedSeconds = 600
        XCTAssertEqual(engine.progress, 1.0, accuracy: 0.01)
    }

    func testTimerEngineDisplayTime() {
        let engine = AMRAPEngine(config: AMRAPConfig(minutes: 10))
        XCTAssertEqual(engine.displayTime, "10:00")
    }

    // MARK: - Timer State Tests

    func testTimerStateEquatable() {
        XCTAssertEqual(TimerState.idle, TimerState.idle)
        XCTAssertEqual(TimerState.running, TimerState.running)
        XCTAssertEqual(TimerState.paused, TimerState.paused)
        XCTAssertEqual(TimerState.completed, TimerState.completed)
        XCTAssertEqual(TimerState.countdown(remaining: 3), TimerState.countdown(remaining: 3))
        XCTAssertNotEqual(TimerState.idle, TimerState.running)
    }
}
