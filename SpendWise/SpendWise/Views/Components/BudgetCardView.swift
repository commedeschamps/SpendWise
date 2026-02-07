import SwiftUI

struct BudgetCardView: View {
    let progress: Double
    let spent: Double
    let budget: Double
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.16))
                        .frame(width: 30, height: 30)
                    Image(systemName: statusIcon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(statusColor)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Budget Usage")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                    Text(statusTitle)
                        .font(Theme.captionFont)
                        .foregroundStyle(statusColor)
                }

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(Theme.subtitleFont)
                    .foregroundStyle(progress >= 1 ? Theme.expense : Theme.textPrimary)
                    .monospacedDigit()
            }

            ProgressBarView(progress: progress)
                .frame(height: 10)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Spent")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                    Text(formatted(spent))
                        .font(Theme.subtitleFont)
                        .foregroundStyle(Theme.textPrimary)
                        .monospacedDigit()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Budget")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                    Text(formatted(budget))
                        .font(Theme.subtitleFont)
                        .foregroundStyle(Theme.textPrimary)
                        .monospacedDigit()
                }
            }

            if budget > 0 {
                Text("Remaining \(formatted(max(0, budget - spent)))")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .cardStyle()
    }

    private func formatted(_ value: Double) -> String {
        Currency.format(value, code: currencyCode)
    }

    private var statusTitle: String {
        guard budget > 0 else { return "No budget limit" }
        if progress >= 1 { return "Over budget" }
        if progress >= 0.75 { return "Close to limit" }
        return "On track"
    }

    private var statusColor: Color {
        guard budget > 0 else { return Theme.accent }
        if progress >= 1 { return Theme.expense }
        if progress >= 0.75 { return Theme.accentAlt }
        return Theme.income
    }

    private var statusIcon: String {
        guard budget > 0 else { return "gauge.with.dots.needle.0percent" }
        if progress >= 1 { return "exclamationmark.triangle.fill" }
        if progress >= 0.75 { return "clock.badge.exclamationmark" }
        return "checkmark.circle.fill"
    }
}

#Preview {
    BudgetCardView(progress: 0.45, spent: 900, budget: 2000, currencyCode: "KZT")
        .padding()
        .background(Theme.background)
}
