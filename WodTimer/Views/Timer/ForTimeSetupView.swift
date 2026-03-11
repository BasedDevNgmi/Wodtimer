import SwiftUI

struct ForTimeSetupView: View {
    @State private var config = ForTimeConfig()
    @State private var showTimer = false
    @State private var showSets = false
    @State private var showInterval = false
    @Environment(\.dismiss) private var dismiss

    private let theme = TimerTheme(for: .forTime)

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                Text("FOR TIME")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(.white)
                    .padding(.bottom, 40)

                Text("As fast as possible for time")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.bottom, 24)

                // Time Cap
                HStack(spacing: 16) {
                    Text("Time cap:")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)

                    NumberPicker(
                        value: $config.timeCapMinutes,
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

                // Optional: Interval Signal
                if showInterval {
                    HStack(spacing: 16) {
                        Text("Signal every:")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white)

                        NumberPicker(
                            value: Binding(
                                get: { config.intervalSignalMinutes ?? 1 },
                                set: { config.intervalSignalMinutes = $0 }
                            ),
                            range: 1...30,
                            borderColor: theme.primaryColor,
                            label: "min"
                        )

                        Button {
                            showInterval = false
                            config.intervalSignalMinutes = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppTheme.textMuted)
                        }
                    }
                    .padding(.bottom, 16)
                } else {
                    Button {
                        showInterval = true
                        config.intervalSignalMinutes = 1
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle")
                            Text("Interval Signal (optional)")
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                Spacer()

                // Notes
                Button {
                } label: {
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
            ActiveTimerView(engine: ForTimeEngine(config: config), timerType: .forTime)
        }
    }
}

#Preview {
    NavigationStack {
        ForTimeSetupView()
    }
    .environment(AppState())
}
