import SwiftUI

struct MixSetupView: View {
    @State private var segments: [MixSetupSegment] = []
    @State private var showTimer = false
    @State private var showAddSegment = false
    @Environment(\.dismiss) private var dismiss

    private let theme = TimerTheme(for: .mix)

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                Text("MIX")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)

                Text("Combine multiple timer types")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.bottom, 24)

                // Segments list
                if segments.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "plus.circle.dashed")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.textMuted)

                        Text("Add timer segments to build\nyour custom workout")
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 24)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(segments.indices, id: \.self) { index in
                                MixSegmentRow(
                                    segment: segments[index],
                                    onDelete: {
                                        segments.remove(at: index)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, AppTheme.paddingLarge)
                    }
                    .frame(maxHeight: 300)
                    .padding(.bottom, 16)
                }

                // Add Segment Button
                Button {
                    showAddSegment = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Segment")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(theme.primaryColor)
                }

                Spacer()

                // Notes
                Button {} label: {
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
                .opacity(segments.isEmpty ? 0.5 : 1.0)
                .disabled(segments.isEmpty)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(.white)
                }
            }
        }
        .sheet(isPresented: $showAddSegment) {
            AddMixSegmentView { segment in
                segments.append(segment)
            }
        }
        .fullScreenCover(isPresented: $showTimer) {
            let config = buildMixConfig()
            ActiveTimerView(engine: MixEngine(config: config), timerType: .mix)
        }
    }

    private func buildMixConfig() -> MixConfig {
        let mixSegments = segments.compactMap { segment -> MixSegment? in
            guard let data = try? JSONEncoder().encode(segment.config) else { return nil }
            return MixSegment(timerType: segment.timerType, configData: data)
        }
        return MixConfig(segments: mixSegments)
    }
}

// MARK: - Supporting Types

struct MixSetupSegment: Identifiable {
    let id = UUID()
    let timerType: TimerType
    let config: any TimerConfiguration
    let summary: String
}

struct MixSegmentRow: View {
    let segment: MixSetupSegment
    let onDelete: () -> Void

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(segment.timerType.color)
                .frame(width: 4, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(segment.timerType.displayName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                Text(segment.summary)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textMuted)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .fill(AppTheme.surface)
        )
    }
}

// MARK: - Add Segment Sheet

struct AddMixSegmentView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (MixSetupSegment) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Choose Timer Type")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.top, 20)

                    ForEach([TimerType.amrap, .forTime, .emom, .tabata], id: \.self) { type in
                        Button {
                            let segment = createDefaultSegment(for: type)
                            onAdd(segment)
                            dismiss()
                        } label: {
                            HStack {
                                Circle()
                                    .fill(type.color)
                                    .frame(width: 12, height: 12)
                                Text(type.displayName)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(type.color)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                    .fill(AppTheme.surface)
                            )
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func createDefaultSegment(for type: TimerType) -> MixSetupSegment {
        switch type {
        case .amrap:
            let config = AMRAPConfig(minutes: 10)
            return MixSetupSegment(timerType: type, config: config, summary: "10 minutes")
        case .forTime:
            let config = ForTimeConfig(timeCapMinutes: 12)
            return MixSetupSegment(timerType: type, config: config, summary: "12 min cap")
        case .emom:
            let config = EMOMConfig(everyMinutes: 1, forMinutes: 10)
            return MixSetupSegment(timerType: type, config: config, summary: "Every 1 min for 10 min")
        case .tabata:
            let config = TabataConfig(rounds: 8, workSeconds: 20, restSeconds: 10)
            return MixSetupSegment(timerType: type, config: config, summary: "8 rounds, 0:20/0:10")
        case .mix:
            return MixSetupSegment(timerType: type, config: MixConfig(), summary: "")
        }
    }
}

#Preview {
    NavigationStack {
        MixSetupView()
    }
    .environment(AppState())
}
