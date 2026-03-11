import SwiftUI

struct WatchHomeView: View {
    @State private var selectedTimer: TimerType?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    Text("WodTimer")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.bottom, 4)

                    ForEach([TimerType.amrap, .forTime, .emom, .tabata], id: \.self) { type in
                        NavigationLink(value: type) {
                            HStack {
                                Circle()
                                    .fill(type.color)
                                    .frame(width: 8, height: 8)
                                Text(type.displayName)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationDestination(for: TimerType.self) { type in
                WatchTimerSetupView(timerType: type)
            }
        }
    }
}

#Preview {
    WatchHomeView()
}
