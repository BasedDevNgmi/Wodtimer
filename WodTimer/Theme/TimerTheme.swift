import SwiftUI

public struct TimerTheme {
    public let primaryColor: Color
    public let gradientColors: [Color]
    public let borderColor: Color

    public init(for type: TimerType) {
        self.primaryColor = type.color
        self.gradientColors = [type.color, type.color.opacity(0.7)]
        self.borderColor = type.color.opacity(0.6)
    }

    public var buttonStyle: some ShapeStyle {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
