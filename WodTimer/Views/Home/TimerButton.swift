import SwiftUI

struct TimerButton: View {
    let type: TimerType
    let isPremium: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [type.color, type.color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: AppTheme.buttonHeight)

                HStack {
                    Spacer()
                    Text(type.displayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .tracking(2)
                    Spacer()
                }

                if isPremium {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            PremiumBadge()
                                .padding(.trailing, 12)
                                .padding(.bottom, -10)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 14) {
        TimerButton(type: .amrap, isPremium: false) {}
        TimerButton(type: .mix, isPremium: true) {}
    }
    .padding()
    .background(.black)
}
