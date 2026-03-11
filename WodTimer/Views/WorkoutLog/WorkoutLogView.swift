import SwiftUI
import SwiftData

struct WorkoutLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var workouts: [WorkoutSession]

    @State private var selectedFilter: TimerType?

    private var filteredWorkouts: [WorkoutSession] {
        guard let filter = selectedFilter else { return workouts }
        return workouts.filter { $0.timerType == filter }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterChip(label: "All", type: nil)
                            ForEach(TimerType.allCases) { type in
                                filterChip(label: type.displayName, type: type)
                            }
                        }
                        .padding(.horizontal, AppTheme.paddingMedium)
                        .padding(.vertical, 12)
                    }

                    if filteredWorkouts.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 48))
                                .foregroundStyle(AppTheme.textMuted)
                            Text("No workouts yet")
                                .font(.system(size: 17))
                                .foregroundStyle(AppTheme.textMuted)
                            Text("Complete a timer to see it here")
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.textMuted.opacity(0.7))
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredWorkouts) { workout in
                                NavigationLink {
                                    WorkoutDetailView(workout: workout)
                                } label: {
                                    WorkoutRow(workout: workout)
                                }
                                .listRowBackground(AppTheme.surface)
                                .listRowSeparatorTint(AppTheme.surfaceLight)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    modelContext.delete(filteredWorkouts[index])
                                }
                                try? modelContext.save()
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Workout Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func filterChip(label: String, type: TimerType?) -> some View {
        Button {
            selectedFilter = type
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(selectedFilter == type ? .white : AppTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selectedFilter == type ? (type?.color ?? .white).opacity(0.3) : AppTheme.surface)
                )
        }
    }
}

struct WorkoutRow: View {
    let workout: WorkoutSession

    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(workout.timerType.color)
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(workout.timerType.displayName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Text(TimeFormatter.adaptive(Int(workout.duration)))
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white)
                }

                HStack {
                    Text(workout.startedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textMuted)

                    if let rounds = workout.roundsCompleted, rounds > 1 {
                        Text("\(rounds) rounds")
                            .font(.system(size: 12))
                            .foregroundStyle(workout.timerType.color.opacity(0.8))
                    }
                }
            }
        }
    }
}

#Preview {
    WorkoutLogView()
        .modelContainer(for: WorkoutSession.self, inMemory: true)
}
