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
            HStack {
                Text(title)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Image(systemName: iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isHero ? Theme.accent : color)
                    .padding(7)
                    .background((isHero ? Theme.accentSoft : color.opacity(0.14)))
                    .clipShape(Circle())
            }

            Text(formattedAmount)
                .font(isHero ? Theme.heroAmountFont : Theme.amountFont)
                .foregroundStyle(isHero ? Theme.textPrimary : color)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .allowsTightening(true)
                .layoutPriority(1)
                .animation(.easeInOut(duration: 0.2), value: amount)

            Text(isHero ? "Available total funds" : metricDescription)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(1)
        }
        .cardStyle(background: isHero ? heroBackground : AnyShapeStyle(Theme.softCardGradient))
    }

    private var heroBackground: AnyShapeStyle {
        AnyShapeStyle(Theme.heroGradient)
    }

    private var formattedAmount: String {
        let sign = amount < 0 ? "-" : ""
        let value = abs(amount)
        return "\(sign)\(Currency.format(value, code: currencyCode))"
    }

    private var iconName: String {
        switch title.lowercased() {
        case "income":
            return "arrow.down.circle.fill"
        case "expenses":
            return "arrow.up.circle.fill"
        case "balance":
            return "wallet.pass.fill"
        default:
            return "chart.line.uptrend.xyaxis"
        }
    }

    private var metricDescription: String {
        switch title.lowercased() {
        case "income":
            return "Cash in"
        case "expenses":
            return "Cash out"
        default:
            return "Net movement"
        }
    }
}

#Preview {
    SummaryCardView(title: "Balance", amount: 1240, currencyCode: "KZT", color: Theme.accent, isHero: true)
        .padding()
        .background(Theme.background)
}
