import SwiftUI
import UIKit

enum Theme {
    static let background = Color(UIColor.systemGroupedBackground)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let elevatedBackground = Color(UIColor.systemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemGroupedBackground)
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    static let separator = Color(UIColor.separator)

    static let accent = Color(red: 0.06, green: 0.49, blue: 0.45)
    static let income = Color(red: 0.16, green: 0.67, blue: 0.38)
    static let expense = Color(red: 0.87, green: 0.33, blue: 0.31)
    static let accentAlt = Color(red: 0.13, green: 0.57, blue: 0.86)
    static let ambientTop = Color(red: 0.86, green: 0.96, blue: 0.93)
    static let ambientBottom = Color(red: 0.96, green: 0.97, blue: 1.0)
    static let darkAmbientTop = Color(red: 0.10, green: 0.17, blue: 0.16)
    static let darkAmbientBottom = Color(red: 0.05, green: 0.08, blue: 0.10)

    static let accentSoft = accent.opacity(0.12)
    static let incomeSoft = income.opacity(0.12)
    static let expenseSoft = expense.opacity(0.12)
    static let accentGlow = accent.opacity(0.28)

    static let heroGradient = LinearGradient(
        colors: [accent.opacity(0.28), accentAlt.opacity(0.22)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let progressGradient = LinearGradient(
        colors: [accent, accentAlt],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let buttonGradient = LinearGradient(
        colors: [accent, accentAlt],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cornerRadius: CGFloat = 18
    static let spacing: CGFloat = 16
    static let compactSpacing: CGFloat = 8

    static let largeTitleFont: Font = scaledAvenir("AvenirNext-Heavy", size: 34, textStyle: .largeTitle)
    static let titleFont: Font = scaledAvenir("AvenirNext-DemiBold", size: 26, textStyle: .title1)
    static let subtitleFont: Font = scaledAvenir("AvenirNext-DemiBold", size: 17, textStyle: .headline)
    static let bodyFont: Font = scaledAvenir("AvenirNext-Regular", size: 16, textStyle: .body)
    static let captionFont: Font = scaledAvenir("AvenirNext-Medium", size: 12, textStyle: .caption1)
    static let amountFont: Font = scaledAvenir("AvenirNext-Bold", size: 22, textStyle: .title2)
    static let heroAmountFont: Font = scaledAvenir("AvenirNext-Bold", size: 30, textStyle: .largeTitle)

    private static func scaledAvenir(_ name: String, size: CGFloat, textStyle: UIFont.TextStyle) -> Font {
        let base = UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
        let scaled = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
        return Font(scaled)
    }
}

struct AppBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Theme.darkAmbientTop, Theme.darkAmbientBottom]
                    : [Theme.ambientTop, Theme.ambientBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Theme.accentGlow)
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: -120, y: -260)

            Circle()
                .fill(Theme.accentAlt.opacity(colorScheme == .dark ? 0.26 : 0.2))
                .frame(width: 260, height: 260)
                .blur(radius: 75)
                .offset(x: 160, y: -200)
        }
        .ignoresSafeArea()
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.subtitleFont)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                Theme.buttonGradient.opacity(isEnabled ? 1 : 0.45),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.24 : 0.16), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .shadow(
                color: Theme.accent.opacity(configuration.isPressed ? 0.18 : 0.32),
                radius: configuration.isPressed ? 6 : 12,
                x: 0,
                y: configuration.isPressed ? 3 : 6
            )
            .animation(.spring(response: 0.24, dampingFraction: 0.78), value: configuration.isPressed)
    }
}
