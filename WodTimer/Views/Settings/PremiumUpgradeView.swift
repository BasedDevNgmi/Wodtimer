import SwiftUI
import StoreKit

struct PremiumUpgradeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(AppTheme.textMuted)
                    }
                }
                .padding()

                Spacer()

                // Premium icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.premiumBadge, AppTheme.premiumBadge.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "star.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 24)

                Text("PREMIUM")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(4)
                    .padding(.bottom, 8)

                Text("Unlock the full WodTimer experience")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.bottom, 40)

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    featureRow(icon: "timer", text: "MIX Timer - Combine multiple timer types")
                    featureRow(icon: "applewatch", text: "Apple Watch companion app")
                    featureRow(icon: "arrow.triangle.2.circlepath", text: "Cloud sync across devices")
                    featureRow(icon: "infinity", text: "Unlimited presets")
                }
                .padding(.horizontal, AppTheme.paddingLarge)

                Spacer()

                // Error
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.danger)
                        .padding(.bottom, 8)
                }

                // Purchase button
                GlowButton(
                    title: isPurchasing ? "PURCHASING..." : "UPGRADE NOW",
                    color: AppTheme.premiumBadge
                ) {
                    Task { await purchase() }
                }
                .disabled(isPurchasing)
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, 12)

                // Restore
                Button {
                    Task { await restorePurchases() }
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textMuted)
                }
                .padding(.bottom, AppTheme.paddingXL)
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.premiumBadge)
                .frame(width: 28)

            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.white)
        }
    }

    private func purchase() async {
        isPurchasing = true
        errorMessage = nil

        do {
            let storeService = StoreService.shared
            try await storeService.purchase()
            appState.isPremium = true
            dismiss()
        } catch StoreError.cancelled {
            // User cancelled
        } catch {
            errorMessage = error.localizedDescription
        }

        isPurchasing = false
    }

    private func restorePurchases() async {
        isPurchasing = true
        errorMessage = nil

        do {
            let storeService = StoreService.shared
            let restored = try await storeService.restorePurchases()
            if restored {
                appState.isPremium = true
                dismiss()
            } else {
                errorMessage = "No previous purchase found"
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isPurchasing = false
    }
}

#Preview {
    PremiumUpgradeView()
        .environment(AppState())
}
