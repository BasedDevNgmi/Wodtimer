import SwiftUI

struct AMRAPSetupView: View {
    @State private var config = AMRAPConfig()
    @State private var showTimer = false
    @State private var notes = ""
    @Environment(\.dismiss) private var dismiss

    private let theme = TimerTheme(for: .amrap)

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                Text("AMRAP")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)

                Text("As many rounds as possible in")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.bottom, 24)

                // Minutes Picker
                NumberPicker(
                    value: $config.minutes,
                    range: 1...99,
                    borderColor: theme.primaryColor,
                    label: "minutes"
                )
                .padding(.bottom, 24)

                // Add Multiple AMRAPs
                if config.segments.count <= 1 {
                    Button {
                        config.segments.append(AMRAPSegment(minutes: 10))
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle")
                            Text("Add multiple AMRAP`s (optional)")
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(config.segments.indices, id: \.self) { index in
                            HStack {
                                Text("AMRAP \(index + 1)")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.white)

                                Spacer()

                                NumberPicker(
                                    value: $config.segments[index].minutes,
                                    range: 1...99,
                                    borderColor: theme.primaryColor
                                )

                                if config.segments.count > 1 {
                                    Button {
                                        config.segments.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(AppTheme.textMuted)
                                    }
                                }
                            }
                        }

                        Button {
                            config.segments.append(AMRAPSegment(minutes: 10))
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add AMRAP")
                            }
                            .font(.system(size: 15))
                            .foregroundStyle(theme.primaryColor)
                        }
                    }
                    .padding(.horizontal, AppTheme.paddingLarge)
                }

                Spacer()

                // Notes
                Button {
                    // Toggle notes input
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
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        // Watch sync
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "applewatch")
                                .font(.system(size: 18))
                            Text("WATCH")
                                .font(.system(size: 8, weight: .medium))
                        }
                        .foregroundStyle(.white)
                    }

                    Button {
                        // Presets
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18))
                            Text("PRESETS")
                                .font(.system(size: 8, weight: .medium))
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showTimer) {
            ActiveTimerView(engine: AMRAPEngine(config: config), timerType: .amrap)
        }
    }
}

#Preview {
    NavigationStack {
        AMRAPSetupView()
    }
    .environment(AppState())
}
