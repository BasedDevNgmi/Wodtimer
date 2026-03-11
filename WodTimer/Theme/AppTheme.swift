import SwiftUI

public enum AppTheme {
    // MARK: - Colors
    public static let background = Color.black
    public static let surface = Color(hex: "1A1A1A")
    public static let surfaceLight = Color(hex: "2A2A2A")
    public static let textPrimary = Color.white
    public static let textSecondary = Color(hex: "9CA3AF")
    public static let textMuted = Color(hex: "6B7280")

    // MARK: - Timer Colors
    public static let amrapColor = Color(hex: "F5A623")
    public static let forTimeColor = Color(hex: "7B8CDE")
    public static let emomColor = Color(hex: "A855F7")
    public static let tabataColor = Color(hex: "34D399")
    public static let mixColor = Color(hex: "6B7280")

    // MARK: - Semantic Colors
    public static let premiumBadge = Color(hex: "F5A623")
    public static let danger = Color(hex: "EF4444")
    public static let success = Color(hex: "22C55E")

    // MARK: - Typography
    public static let titleFont = Font.system(size: 36, weight: .bold, design: .default)
    public static let headlineFont = Font.system(size: 28, weight: .bold, design: .default)
    public static let timerFont = Font.system(size: 72, weight: .bold, design: .monospaced)
    public static let timerLargeFont = Font.system(size: 96, weight: .bold, design: .monospaced)
    public static let bodyFont = Font.system(size: 17, weight: .regular, design: .default)
    public static let captionFont = Font.system(size: 13, weight: .medium, design: .default)
    public static let numberInputFont = Font.system(size: 42, weight: .semibold, design: .monospaced)

    // MARK: - Spacing
    public static let paddingSmall: CGFloat = 8
    public static let paddingMedium: CGFloat = 16
    public static let paddingLarge: CGFloat = 24
    public static let paddingXL: CGFloat = 32

    // MARK: - Corner Radius
    public static let cornerRadiusSmall: CGFloat = 8
    public static let cornerRadiusMedium: CGFloat = 12
    public static let cornerRadiusLarge: CGFloat = 16
    public static let cornerRadiusXL: CGFloat = 24
    public static let cornerRadiusFull: CGFloat = 100

    // MARK: - Button
    public static let buttonHeight: CGFloat = 60
    public static let buttonCornerRadius: CGFloat = 30
}
