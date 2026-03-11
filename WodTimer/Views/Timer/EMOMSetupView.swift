import SwiftUI

struct EMOMSetupView: View {
    @State private var config = EMOMConfig()
    @State private var showTimer = false
    @State private var showSets = false
    @Environment(\.dismiss) private var dismiss

    private let theme = TimerTheme(for: .emom)

    private var subtitle: String {
        "Every minute on a minute for \(config.forMinutes) minutes"
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                Text("EMOM")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)

                Text(subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 32)

                // Every X minutes
                HStack(spacing: 16) {
                    Text("Every")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)

                    NumberPicker(
                        value: $config.everyMinutes,
                        range: 1...30,
                        borderColor: theme.primaryColor
                    )
                }
                .padding(.bottom, 20)

                // For Y minutes
                HStack(spacing: 16) {
                    Text("for")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)

                    NumberPicker(
                        value: $config.forMinutes,
                        range: 1...99,
                        borderColor: theme.primaryColor
                    )
                }
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
                    .padding(.bottom, 16)
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
                    .padding(.bottom, 8)
                }

                // Death By toggle
                Button {
                    config.deathBy.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: config.deathBy ? "infinity.circle.fill" : "infinity.circle")
                            .font(.system(size: 18))
                        Text("As long as possible (\"Death By\")")
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(config.deathBy ? theme.primaryColor : AppTheme.textMuted)
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
            ActiveTimerView(engine: EMOMEngine(config: config), timerType: .emom)
        }
    }
}

#Preview {
    NavigationStack {
        EMOMSetupView()
    }
    .environment(AppState())
}
