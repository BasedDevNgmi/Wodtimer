import SwiftUI
import SwiftData

struct PresetsListView: View {
    let timerType: TimerType
    let onSelect: (Preset) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allPresets: [Preset]

    private var presets: [Preset] {
        allPresets.filter { $0.timerType == timerType }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if presets.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.textMuted)
                        Text("No presets saved")
                            .font(.system(size: 17))
                            .foregroundStyle(AppTheme.textMuted)
                        Text("Save a timer configuration to use it later")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textMuted.opacity(0.7))
                    }
                } else {
                    List {
                        ForEach(presets) { preset in
                            Button {
                                onSelect(preset)
                                dismiss()
                            } label: {
                                PresetRow(preset: preset)
                            }
                            .listRowBackground(AppTheme.surface)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                modelContext.delete(presets[index])
                            }
                            try? modelContext.save()
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("\(timerType.displayName) Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct PresetRow: View {
    let preset: Preset

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(preset.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textMuted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textMuted)
        }
    }
}
