import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showMenu = false
    @State private var selectedTimer: TimerType?
    @State private var showWorkoutLog = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerBar

                    Spacer()

                    // Logo
                    VStack(spacing: 4) {
                        Text("wodtimer")
                            .font(.system(size: 40, weight: .bold, design: .default))
                            .foregroundStyle(.white)
                            .tracking(-1)
                        Text("TIMER")
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .foregroundStyle(.white.opacity(0.8))
                            .tracking(6)
                    }
                    .padding(.bottom, 40)

                    // Timer Buttons
                    VStack(spacing: 14) {
                        ForEach(TimerType.allCases) { type in
                            TimerButton(type: type, isPremium: type.isPremium && !appState.isPremium) {
                                if type.isPremium && !appState.isPremium {
                                    selectedTimer = type
                                } else {
                                    selectedTimer = type
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.paddingLarge)

                    Spacer()

                    // Workout Log Button
                    Button {
                        showWorkoutLog = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "list.clipboard")
                                .font(.system(size: 20))
                            Text("WORKOUT LOG")
                                .font(.system(size: 16, weight: .semibold))
                                .tracking(2)
                        }
                        .foregroundStyle(.white)
                    }
                    .padding(.bottom, AppTheme.paddingXL)
                }
            }
            .navigationDestination(item: $selectedTimer) { type in
                timerSetupView(for: type)
            }
            .sheet(isPresented: $showWorkoutLog) {
                WorkoutLogView()
            }
            .sheet(isPresented: $showMenu) {
                SettingsView()
            }
        }
    }

    private var headerBar: some View {
        HStack {
            Button {
                showMenu = true
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
                // Notifications placeholder
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, AppTheme.paddingMedium)
        .padding(.top, AppTheme.paddingSmall)
    }

    @ViewBuilder
    private func timerSetupView(for type: TimerType) -> some View {
        switch type {
        case .amrap:
            AMRAPSetupView()
        case .forTime:
            ForTimeSetupView()
        case .emom:
            EMOMSetupView()
        case .tabata:
            TabataSetupView()
        case .mix:
            if appState.isPremium {
                MixSetupView()
            } else {
                PremiumUpgradeView()
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}
