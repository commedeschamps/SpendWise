import SwiftUI

struct BudgetCardView: View {
    let progress: Double
    let spent: Double
    let budget: Double
    let currencySymbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text("Budget Usage")
                .font(Theme.captionFont)
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
        .cardStyle()
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
