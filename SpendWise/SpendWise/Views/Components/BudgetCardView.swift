import SwiftUI

struct BudgetCardView: View {
    let progress: Double
    let spent: Double
    let budget: Double
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            HStack {
                Text("Budget Usage")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(Theme.captionFont.weight(.semibold))
                    .foregroundStyle(progress >= 1 ? Theme.expense : Theme.textSecondary)
            }

            ProgressBarView(progress: progress)
                .frame(height: 10)

            HStack {
                Text("Spent \(formatted(spent))")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("Budget \(formatted(budget))")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .cardStyle()
    }

    private func formatted(_ value: Double) -> String {
        Currency.format(value, code: currencyCode)
    }
}

#Preview {
    BudgetCardView(progress: 0.45, spent: 900, budget: 2000, currencyCode: "KZT")
        .padding()
        .background(Theme.background)
}
