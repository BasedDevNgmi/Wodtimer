import SwiftUI

struct WatchTimerSetupView: View {
    let timerType: TimerType
    @State private var minutes: Int = 10
    @State private var showTimer = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(timerType.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(timerType.color)

                Text(timerType.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // Minutes picker
                VStack(spacing: 4) {
                    Text("\(minutes)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                    Text("minutes")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .focusable()
                .digitalCrownRotation(
                    Binding(
                        get: { Double(minutes) },
                        set: { minutes = max(1, min(99, Int($0))) }
                    ),
                    from: 1, through: 99, by: 1,
                    sensitivity: .medium
                )

                Button {
                    showTimer = true
                } label: {
                    Text("START")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(timerType.color)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
        }
        .fullScreenCover(isPresented: $showTimer) {
            WatchActiveTimerView(
                engine: createEngine(),
                timerType: timerType
            )
        }
    }

    private func createEngine() -> TimerEngine {
        switch timerType {
        case .amrap:
            return AMRAPEngine(config: AMRAPConfig(minutes: minutes))
        case .forTime:
            return ForTimeEngine(config: ForTimeConfig(timeCapMinutes: minutes))
        case .emom:
            return EMOMEngine(config: EMOMConfig(everyMinutes: 1, forMinutes: minutes))
        case .tabata:
            return TabataEngine(config: TabataConfig(rounds: 3, workSeconds: minutes * 20, restSeconds: minutes * 10))
        case .mix:
            return TimerEngine()
        }
    }
}

#Preview {
    WatchTimerSetupView(timerType: .amrap)
}
