import SwiftUI

struct BudgetCardView: View {
    let progress: Double
    let spent: Double
    let budget: Double
    let currencySymbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text("Monthly Budget")
                .font(Theme.subtitleFont)
                .foregroundStyle(Theme.textSecondary)

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
        .padding(Theme.spacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, x: 0, y: 8)
    }

    private func formatted(_ value: Double) -> String {
        "\(currencySymbol)\(String(format: "%.2f", value))"
    }
}

#Preview {
    BudgetCardView(progress: 0.45, spent: 900, budget: 2000, currencySymbol: "$")
        .padding()
        .background(Theme.background)
}
