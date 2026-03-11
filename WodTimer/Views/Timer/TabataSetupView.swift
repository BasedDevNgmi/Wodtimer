import SwiftUI

struct TabataSetupView: View {
    @State private var config = TabataConfig()
    @State private var showTimer = false
    @State private var showSets = false
    @Environment(\.dismiss) private var dismiss

    private let theme = TimerTheme(for: .tabata)

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                Text("TABATA")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(.white)
                    .padding(.bottom, 32)

                Text("Set your Tabata Timer")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.bottom, 32)

                // Rounds
                NumberPicker(
                    value: $config.rounds,
                    range: 1...50,
                    borderColor: theme.primaryColor,
                    label: "Rounds"
                )
                .padding(.bottom, 20)

                // Work Time
                TimePicker(
                    totalSeconds: $config.workSeconds,
                    borderColor: theme.primaryColor,
                    label: "Work"
                )
                .padding(.bottom, 20)

                // Rest Time
                TimePicker(
                    totalSeconds: $config.restSeconds,
                    borderColor: theme.primaryColor,
                    label: "Rest"
                )
                .padding(.bottom, 24)

                // Optional: Sets
                if showSets {
                    HStack(spacing: 16) {
                        Text("Sets:")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)

                        NumberPicker(
                            value: $config.sets,
                            range: 1...20,
                            borderColor: theme.primaryColor
                        )

                        Button {
                            showSets = false
                            config.sets = 1
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppTheme.textMuted)
                        }
                    }
                } else {
                    Button {
                        showSets = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle")
                            Text("Add sets (optional)")
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                Spacer()

                // Notes
                Button {} label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                        Text("Add notes")
                    }
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.bottom, 16)

                // Start Button
                GlowButton(title: "START TIMER", color: theme.primaryColor) {
                    showTimer = true
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, AppTheme.paddingXL)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(.white)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button {} label: {
                        VStack(spacing: 2) {
                            Image(systemName: "applewatch").font(.system(size: 18))
                            Text("WATCH").font(.system(size: 8, weight: .medium))
                        }.foregroundStyle(.white)
                    }
                    Button {} label: {
                        VStack(spacing: 2) {
                            Image(systemName: "square.and.arrow.up").font(.system(size: 18))
                            Text("PRESETS").font(.system(size: 8, weight: .medium))
                        }.foregroundStyle(.white)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showTimer) {
            ActiveTimerView(engine: TabataEngine(config: config), timerType: .tabata)
        }
    }
}

#Preview {
    NavigationStack {
        TabataSetupView()
    }
    .environment(AppState())
}
