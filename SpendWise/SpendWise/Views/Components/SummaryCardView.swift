import SwiftUI

struct SummaryCardView: View {
    let title: String
    let amount: Double
    let currencySymbol: String
    let color: Color
    let isHero: Bool

    init(title: String, amount: Double, currencySymbol: String, color: Color, isHero: Bool = false) {
        self.title = title
        self.amount = amount
        self.currencySymbol = currencySymbol
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
                .foregroundStyle(color)
                .animation(.easeInOut(duration: 0.2), value: amount)
        }
        .cardStyle()
    }

    private var formattedAmount: String {
        let sign = amount < 0 ? "-" : ""
        let value = abs(amount)
        return "\(sign)\(currencySymbol)\(String(format: "%.2f", value))"
    }
}

#Preview {
    SummaryCardView(title: "Balance", amount: 1240, currencySymbol: "$", color: Theme.accent, isHero: true)
        .padding()
        .background(Theme.background)
}
