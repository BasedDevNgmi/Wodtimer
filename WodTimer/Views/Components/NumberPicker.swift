import SwiftUI

struct NumberPicker: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let borderColor: Color
    let label: String?

    init(value: Binding<Int>, range: ClosedRange<Int> = 1...99, borderColor: Color = .white.opacity(0.3), label: String? = nil) {
        self._value = value
        self.range = range
        self.borderColor = borderColor
        self.label = label
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(borderColor, lineWidth: 2)
                    .frame(width: 80, height: 80)

                TextField("", value: $value, format: .number)
                    .font(AppTheme.numberInputFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .frame(width: 70)
                    .onChange(of: value) { _, newValue in
                        value = min(max(newValue, range.lowerBound), range.upperBound)
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
    NumberPicker(value: .constant(10), borderColor: .orange, label: "minutes")
        .padding()
        .background(.black)
}
