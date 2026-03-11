import SwiftUI
import SwiftData

struct CompletionView: View {
    let timerType: TimerType
    let duration: TimeInterval
    let roundsCompleted: Int
    let engine: TimerEngine

    @State private var notes = ""
    @State private var saved = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private var theme: TimerTheme { TimerTheme(for: timerType) }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Checkmark
                ZStack {
                    Circle()
                        .fill(theme.primaryColor.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(theme.primaryColor)
                }
                .padding(.bottom, 24)

                // Title
                Text("WORKOUT COMPLETE")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(2)
                    .padding(.bottom, 8)

                Text(timerType.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(theme.primaryColor)
                    .padding(.bottom, 32)

                // Stats
                VStack(spacing: 16) {
                    statRow(label: "Duration", value: TimeFormatter.adaptive(Int(duration)))

                    if roundsCompleted > 1 {
                        statRow(label: "Rounds", value: "\(roundsCompleted)")
                    }

                    if engine.totalSets > 1 {
                        statRow(label: "Sets", value: "\(engine.currentSet)/\(engine.totalSets)")
                    }
                }
                .padding(.horizontal, AppTheme.paddingXL)
                .padding(.bottom, 32)

                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    TextField("How did it go?", text: $notes, axis: .vertical)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .fill(AppTheme.surface)
                        )
                        .lineLimit(3...6)
                }
                .padding(.horizontal, AppTheme.paddingLarge)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    GlowButton(title: saved ? "SAVED" : "SAVE WORKOUT", color: theme.primaryColor) {
                        saveWorkout()
                    }
                    .disabled(saved)
                    .opacity(saved ? 0.6 : 1)

                    Button {
                        dismiss()
                    } label: {
                        Text("DISMISS")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppTheme.textMuted)
                            .tracking(1)
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, AppTheme.paddingXL)
            }
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .fill(AppTheme.surface)
        )
    }

    private func saveWorkout() {
        let configData = (try? JSONEncoder().encode(AnyTimerConfig(AMRAPConfig()))) ?? Data()
        let session = WorkoutSession(
            timerType: timerType,
            configData: configData,
            startedAt: Date().addingTimeInterval(-duration),
            completedAt: Date(),
            duration: duration,
            notes: notes,
            roundsCompleted: roundsCompleted
        )
        modelContext.insert(session)
        try? modelContext.save()
        saved = true
        HapticManager.shared.play(.workoutComplete)
    }
}

#Preview {
    CompletionView(
        timerType: .amrap,
        duration: 600,
        roundsCompleted: 5,
        engine: AMRAPEngine(config: AMRAPConfig(minutes: 10))
    )
}
