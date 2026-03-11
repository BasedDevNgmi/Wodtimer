import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutSession
    @State private var isEditing = false
    @State private var editedNotes: String = ""
    @Environment(\.modelContext) private var modelContext

    private var theme: TimerTheme { TimerTheme(for: workout.timerType) }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(workout.timerType.displayName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(theme.primaryColor)

                        Text(workout.startedAt.formatted(date: .complete, time: .shortened))
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.top, 20)

                    // Duration
                    VStack(spacing: 4) {
                        Text(TimeFormatter.adaptive(Int(workout.duration)))
                            .font(.system(size: 56, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)

                        Text("TOTAL TIME")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textMuted)
                            .tracking(2)
                    }

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        if let rounds = workout.roundsCompleted {
                            statCard(label: "Rounds", value: "\(rounds)")
                        }
                        statCard(label: "Type", value: workout.timerType.displayName)
                    }
                    .padding(.horizontal, AppTheme.paddingMedium)

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Notes")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)

                            Spacer()

                            Button {
                                if isEditing {
                                    workout.notes = editedNotes
                                    workout.updatedAt = Date()
                                    try? modelContext.save()
                                } else {
                                    editedNotes = workout.notes
                                }
                                isEditing.toggle()
                            } label: {
                                Text(isEditing ? "Save" : "Edit")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(theme.primaryColor)
                            }
                        }

                        if isEditing {
                            TextField("Add notes...", text: $editedNotes, axis: .vertical)
                                .font(.system(size: 15))
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                        .fill(AppTheme.surface)
                                )
                                .lineLimit(3...8)
                        } else if !workout.notes.isEmpty {
                            Text(workout.notes)
                                .font(.system(size: 15))
                                .foregroundStyle(.white.opacity(0.9))
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                        .fill(AppTheme.surface)
                                )
                        } else {
                            Text("No notes")
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textMuted)
                                .padding(12)
                        }
                    }
                    .padding(.horizontal, AppTheme.paddingMedium)
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func statCard(label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppTheme.textMuted)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .fill(AppTheme.surface)
        )
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: WorkoutSession(
            timerType: .amrap,
            configData: Data(),
            duration: 600,
            notes: "Felt great today!"
        ))
    }
}
