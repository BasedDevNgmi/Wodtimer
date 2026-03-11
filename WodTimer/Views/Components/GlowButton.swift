import SwiftUI

struct GlowButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .tracking(2)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .shadow(color: color.opacity(0.4), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        GlowButton(title: "START TIMER", color: .orange) {}
        GlowButton(title: "START TIMER", color: .blue) {}
    }
    .padding()
    .background(.black)
}
