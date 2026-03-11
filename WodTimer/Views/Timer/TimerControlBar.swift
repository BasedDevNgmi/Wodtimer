import SwiftUI

struct TimerControlBar: View {
    let state: TimerState
    let color: Color
    let onStart: () -> Void
    let onPause: () -> Void
    let onReset: () -> Void
    let onStop: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            switch state {
            case .idle:
                // Single large start button
                startButton
                    .frame(maxWidth: .infinity)

            case .countdown:
                // Cancel button during countdown
                controlButton(icon: "xmark", label: "CANCEL", color: AppTheme.textMuted) {
                    onReset()
                }
                .frame(maxWidth: .infinity)

            case .running:
                // Pause + Stop
                controlButton(icon: "pause.fill", label: "PAUSE", color: color) {
                    onPause()
                }
                .frame(maxWidth: .infinity)

                controlButton(icon: "stop.fill", label: "FINISH", color: AppTheme.danger) {
                    onStop()
                }

            case .paused:
                // Resume + Reset + Stop
                controlButton(icon: "play.fill", label: "RESUME", color: color) {
                    onStart()
                }
                .frame(maxWidth: .infinity)

                controlButton(icon: "arrow.counterclockwise", label: "RESET", color: AppTheme.textMuted) {
                    onReset()
                }

                controlButton(icon: "stop.fill", label: "FINISH", color: AppTheme.danger) {
                    onStop()
                }

            case .completed:
                EmptyView()
            }
        }
    }

    private var startButton: some View {
        Button(action: onStart) {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .font(.system(size: 20))
                Text("START")
                    .font(.system(size: 18, weight: .bold))
                    .tracking(2)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .shadow(color: color.opacity(0.4), radius: 16, y: 6)
        }
        .buttonStyle(.plain)
    }

    private func controlButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(color)
                }

                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color.opacity(0.8))
                    .tracking(1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 40) {
        TimerControlBar(state: .idle, color: .orange, onStart: {}, onPause: {}, onReset: {}, onStop: {})
        TimerControlBar(state: .running, color: .blue, onStart: {}, onPause: {}, onReset: {}, onStop: {})
        TimerControlBar(state: .paused, color: .purple, onStart: {}, onPause: {}, onReset: {}, onStop: {})
    }
    .padding()
    .background(.black)
}
