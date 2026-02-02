import SwiftUI

struct SummaryCardView: View {
    let title: String
    let amount: Double
    let currencyCode: String
    let color: Color
    let isHero: Bool

    init(title: String, amount: Double, currencyCode: String, color: Color, isHero: Bool = false) {
        self.title = title
        self.amount = amount
        self.currencyCode = currencyCode
        self.color = color
        self.isHero = isHero
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text(title)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)

            Text(formattedAmount)
                .font(isHero ? Theme.heroAmountFont : Theme.amountFont)
                .foregroundStyle(isHero ? Theme.textPrimary : color)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .allowsTightening(true)
                .layoutPriority(1)
                .animation(.easeInOut(duration: 0.2), value: amount)
        }
        .cardStyle(background: isHero ? heroBackground : AnyShapeStyle(Theme.cardBackground))
    }

    private var heroBackground: AnyShapeStyle {
        AnyShapeStyle(
            LinearGradient(
                colors: [Theme.accentSoft, Theme.accentSoft.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var formattedAmount: String {
        let sign = amount < 0 ? "-" : ""
        let value = abs(amount)
        return "\(sign)\(Currency.format(value, code: currencyCode))"
    }
}

#Preview {
    SummaryCardView(title: "Balance", amount: 1240, currencyCode: "KZT", color: Theme.accent, isHero: true)
        .padding()
        .background(Theme.background)
}
