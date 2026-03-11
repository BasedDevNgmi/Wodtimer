import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showPremiumUpgrade = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                List {
                    // Account Section
                    Section {
                        if AuthService.shared.isAuthenticated {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(AppTheme.textSecondary)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(AuthService.shared.currentUser?.displayName ?? "User")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text("Signed in with Apple")
                                        .font(.system(size: 13))
                                        .foregroundStyle(AppTheme.textMuted)
                                }
                            }

                            Button(role: .destructive) {
                                Task {
                                    await AuthService.shared.signOut()
                                    appState.isAuthenticated = false
                                }
                            } label: {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                    .foregroundStyle(AppTheme.danger)
                            }
                        } else {
                            Button {
                                appState.requiresAuth = true
                                dismiss()
                            } label: {
                                Label("Sign In", systemImage: "person.crop.circle.badge.plus")
                                    .foregroundStyle(.white)
                            }
                        }
                    } header: {
                        Text("Account")
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    .listRowBackground(AppTheme.surface)

                    // Premium Section
                    Section {
                        if appState.isPremium {
                            HStack {
                                Label("Premium", systemImage: "star.fill")
                                    .foregroundStyle(AppTheme.premiumBadge)
                                Spacer()
                                Text("Active")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppTheme.success)
                            }
                        } else {
                            Button {
                                showPremiumUpgrade = true
                            } label: {
                                HStack {
                                    Label("Upgrade to Premium", systemImage: "star.fill")
                                        .foregroundStyle(AppTheme.premiumBadge)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13))
                                        .foregroundStyle(AppTheme.textMuted)
                                }
                            }
                        }
                    } header: {
                        Text("Premium")
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    .listRowBackground(AppTheme.surface)

                    // Sound & Haptics Section
                    Section {
                        Toggle(isOn: Binding(
                            get: { SoundManager.shared.isMuted },
                            set: { SoundManager.shared.isMuted = $0 }
                        )) {
                            Label("Mute Sounds", systemImage: "speaker.slash")
                                .foregroundStyle(.white)
                        }
                        .tint(AppTheme.amrapColor)
                    } header: {
                        Text("Sound & Haptics")
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    .listRowBackground(AppTheme.surface)

                    // About Section
                    Section {
                        HStack {
                            Text("Version")
                                .foregroundStyle(.white)
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(AppTheme.textMuted)
                        }
                    } header: {
                        Text("About")
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    .listRowBackground(AppTheme.surface)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showPremiumUpgrade) {
                PremiumUpgradeView()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
