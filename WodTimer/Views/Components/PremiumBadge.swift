import SwiftUI

struct PremiumBadge: View {
    var body: some View {
        Text("PREMIUM")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.premiumBadge)
            )
    }
}

#Preview {
    PremiumBadge()
        .padding()
        .background(.black)
}
