import SwiftUI

struct WatchActiveTimerView: View {
    @State var engine: TimerEngine
    let timerType: TimerType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 4) {
            // Phase indicator for Tabata
            if let tabata = engine as? TabataEngine {
                Text(tabata.isWorkPhase ? "WORK" : "REST")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tabata.isWorkPhase ? timerType.color : .red)
            }

            // Timer display
            Group {
                switch engine.state {
                case .countdown(let remaining):
                    Text("\(remaining)")
                        .font(.system(size: 52, weight: .bold, design: .monospaced))
                        .foregroundStyle(timerType.color)

                default:
                    Text(displayTime)
                        .font(.system(size: 38, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.6)
                }
            }

            // Round info
            if engine.totalRounds > 1 {
                Text("Round \(engine.currentRound)/\(engine.totalRounds)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(timerType.color)
                        .frame(width: geo.size.width * engine.progress, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.vertical, 4)

            // Controls
            HStack(spacing: 16) {
                switch engine.state {
                case .idle:
                    Button {
                        engine.start()
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(timerType.color)
                    }
                    .buttonStyle(.plain)

                case .running:
                    Button { engine.pause() } label: {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(timerType.color)
                    }
                    .buttonStyle(.plain)

                    Button { engine.stop() } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)

                case .paused:
                    Button { engine.start() } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(timerType.color)
                    }
                    .buttonStyle(.plain)

                    Button { engine.reset() } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                case .countdown:
                    Button { engine.reset() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                case .completed:
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.green)

                        Button("Done") { dismiss() }
                            .font(.system(size: 13))
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .onChange(of: engine.state) { _, newState in
            if newState == .running || newState == .completed {
                HapticManager.shared.play(.phaseChange)
            }
        }
    }

    private var displayTime: String {
        if let ft = engine as? ForTimeEngine {
            return ft.elapsedDisplayTime
        }
        if let tabata = engine as? TabataEngine {
            return tabata.phaseDisplayTime
        }
        if let emom = engine as? EMOMEngine {
            return emom.roundDisplayTime
        }
        return engine.displayTime
    }
}

#Preview {
    WatchActiveTimerView(
        engine: AMRAPEngine(config: AMRAPConfig(minutes: 10)),
        timerType: .amrap
    )
}
