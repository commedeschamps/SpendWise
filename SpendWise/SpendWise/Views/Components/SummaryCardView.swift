import SwiftUI

struct SummaryCardView: View {
    let title: String
    let amount: Double
    let currencySymbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text(title)
                .font(Theme.subtitleFont)
                .foregroundStyle(Theme.textSecondary)

            Text(formattedAmount)
                .font(Theme.titleFont)
                .foregroundStyle(color)
        }
        .padding(Theme.spacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, x: 0, y: 8)
    }

    private var formattedAmount: String {
        let sign = amount < 0 ? "-" : ""
        let value = abs(amount)
        return "\(sign)\(currencySymbol)\(String(format: "%.2f", value))"
    }
}

#Preview {
    SummaryCardView(title: "Balance", amount: 1240, currencySymbol: "$", color: Theme.accent)
        .padding()
        .background(Theme.background)
}
