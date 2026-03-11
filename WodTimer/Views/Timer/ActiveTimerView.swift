import SwiftUI

struct ActiveTimerView: View {
    @State var engine: TimerEngine
    let timerType: TimerType
    @State private var showCompletion = false
    @Environment(\.dismiss) private var dismiss

    private var theme: TimerTheme { TimerTheme(for: timerType) }

    private var isForTime: Bool { timerType == .forTime }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar
                topBar
                    .padding(.top, 8)

                Spacer()

                // Phase indicator (for Tabata/EMOM)
                phaseIndicator

                // Main Timer Display
                timerDisplay
                    .padding(.bottom, 16)

                // Round/Set info
                roundInfo
                    .padding(.bottom, 24)

                // Progress Ring
                progressRing
                    .padding(.bottom, 32)

                Spacer()

                // Controls
                TimerControlBar(
                    state: engine.state,
                    color: theme.primaryColor,
                    onStart: { engine.start() },
                    onPause: { engine.pause() },
                    onReset: { engine.reset() },
                    onStop: {
                        engine.stop()
                        showCompletion = true
                    }
                )
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, AppTheme.paddingXL)
            }
        }
        .onChange(of: engine.state) { _, newState in
            if newState == .completed {
                showCompletion = true
            }
        }
        .fullScreenCover(isPresented: $showCompletion) {
            CompletionView(
                timerType: timerType,
                duration: engine.elapsedSeconds,
                roundsCompleted: engine.currentRound,
                engine: engine
            )
        }
        .statusBarHidden(true)
    }

    // MARK: - Background

    private var backgroundColor: Color {
        switch engine.state {
        case .idle, .countdown:
            return AppTheme.background
        case .running:
            if let tabata = engine as? TabataEngine, tabata.phase == .rest {
                return Color(hex: "1A0000")  // Subtle dark red for rest
            }
            return AppTheme.background
        case .paused:
            return Color(hex: "1A1A00")  // Subtle dark yellow for paused
        case .completed:
            return AppTheme.background
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                engine.reset()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Text(timerType.displayName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(theme.primaryColor)
                .tracking(2)

            Spacer()

            // Mute button
            Button {
                SoundManager.shared.isMuted.toggle()
            } label: {
                Image(systemName: SoundManager.shared.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, AppTheme.paddingMedium)
    }

    // MARK: - Phase Indicator

    @ViewBuilder
    private var phaseIndicator: some View {
        if let tabata = engine as? TabataEngine {
            Text(tabata.isWorkPhase ? "WORK" : "REST")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(tabata.isWorkPhase ? theme.primaryColor : AppTheme.danger)
                .padding(.bottom, 8)
        } else if engine is EMOMEngine {
            Text("ROUND \(engine.currentRound)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(theme.primaryColor)
                .padding(.bottom, 8)
        }
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        Group {
            switch engine.state {
            case .countdown(let remaining):
                Text("\(remaining)")
                    .font(.system(size: 120, weight: .bold, design: .monospaced))
                    .foregroundStyle(theme.primaryColor)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.3), value: remaining)

            default:
                VStack(spacing: 4) {
                    // Main time
                    Text(mainDisplayTime)
                        .font(AppTheme.timerLargeFont)
                        .foregroundStyle(.white)
                        .monospacedDigit()

                    // Sub time (e.g., round time for EMOM)
                    if let subTime = subDisplayTime {
                        Text(subTime)
                            .font(.system(size: 28, weight: .medium, design: .monospaced))
                            .foregroundStyle(theme.primaryColor.opacity(0.8))
                    }
                }
            }
        }
    }

    private var mainDisplayTime: String {
        if isForTime, let ftEngine = engine as? ForTimeEngine {
            return ftEngine.elapsedDisplayTime
        }
        if let tabata = engine as? TabataEngine {
            return tabata.phaseDisplayTime
        }
        if let emom = engine as? EMOMEngine {
            return emom.roundDisplayTime
        }
        return engine.displayTime
    }

    private var subDisplayTime: String? {
        if let emom = engine as? EMOMEngine {
            return "Total: " + TimeFormatter.mmss(Int(emom.remainingSeconds))
        }
        if let tabata = engine as? TabataEngine {
            return "Total: " + TimeFormatter.mmss(Int(tabata.remainingSeconds))
        }
        return nil
    }

    // MARK: - Round Info

    @ViewBuilder
    private var roundInfo: some View {
        HStack(spacing: 24) {
            if engine.totalRounds > 1 {
                VStack(spacing: 2) {
                    Text("ROUND")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.textMuted)
                    Text("\(engine.currentRound)/\(engine.totalRounds)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }
            }

            if engine.totalSets > 1 {
                VStack(spacing: 2) {
                    Text("SET")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.textMuted)
                    Text("\(engine.currentSet)/\(engine.totalSets)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - Progress Ring

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.surfaceLight, lineWidth: 4)
                .frame(width: 60, height: 60)

            Circle()
                .trim(from: 0, to: engine.progress)
                .stroke(theme.primaryColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: engine.progress)
        }
    }
}

#Preview {
    ActiveTimerView(engine: AMRAPEngine(config: AMRAPConfig(minutes: 10)), timerType: .amrap)
}
