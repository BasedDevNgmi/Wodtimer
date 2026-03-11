import SwiftUI

struct TimePicker: View {
    @Binding var totalSeconds: Int
    let borderColor: Color
    let label: String?

    private var minutes: Int {
        totalSeconds / 60
    }
    private var seconds: Int {
        totalSeconds % 60
    }

    init(totalSeconds: Binding<Int>, borderColor: Color = .white.opacity(0.3), label: String? = nil) {
        self._totalSeconds = totalSeconds
        self.borderColor = borderColor
        self.label = label
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(borderColor, lineWidth: 2)
                    .frame(width: 120, height: 80)

                HStack(spacing: 2) {
                    // Minutes
                    TextField("", value: Binding(
                        get: { minutes },
                        set: { totalSeconds = $0 * 60 + seconds }
                    ), format: .number)
                    .font(AppTheme.numberInputFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .frame(width: 45)

                    Text(":")
                        .font(AppTheme.numberInputFont)
                        .foregroundStyle(.white)

                    // Seconds
                    TextField("", value: Binding(
                        get: { seconds },
                        set: { totalSeconds = minutes * 60 + min($0, 59) }
                    ), format: .number.precision(.integerLength(2)))
                    .font(AppTheme.numberInputFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.numberPad)
                    .frame(width: 45)
                }
            }

            if let label {
                Text(label)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    TimePicker(totalSeconds: .constant(120), borderColor: .green, label: "Work")
        .padding()
        .background(.black)
}
