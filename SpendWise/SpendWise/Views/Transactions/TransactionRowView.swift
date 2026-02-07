import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    @AppStorage("currencyCode") private var currencyCode = "KZT"

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            iconBadge

            VStack(alignment: .leading, spacing: Theme.compactSpacing) {
                HStack(spacing: 6) {
                    Text(transaction.title)
                        .font(Theme.subtitleFont)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    if transaction.isRecurring {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.accentAlt)
                    }
                }

                HStack(spacing: 6) {
                    categoryBadge
                    Text(dateString)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
            }
            .layoutPriority(1)

            Spacer(minLength: Theme.compactSpacing)

            VStack(alignment: .trailing, spacing: 4) {
                Text(amountString)
                    .font(Theme.subtitleFont.weight(.bold))
                    .foregroundStyle(transaction.type == .income ? Theme.income : Theme.expense)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                    .allowsTightening(true)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        (transaction.type == .income ? Theme.incomeSoft : Theme.expenseSoft)
                            .opacity(0.9)
                    )
                    .clipShape(Capsule())
                Text(transaction.type == .income ? "Income" : "Expense")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }
            .frame(minWidth: 124, maxWidth: 168, alignment: .trailing)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(badgeBackground)
                .frame(width: 40, height: 40)
            Image(systemName: iconName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(badgeForeground)
        }
        .accessibilityHidden(true)
    }

    private var categoryBadge: some View {
        Text(transaction.category.title)
            .font(Theme.captionFont)
            .foregroundStyle(Theme.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Theme.elevatedBackground.opacity(0.8))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Theme.separator.opacity(0.22), lineWidth: 1)
            )
            .fixedSize(horizontal: true, vertical: false)
    }

    private var amountString: String {
        let sign = transaction.type == .expense ? "-" : "+"
        return "\(sign)\(Currency.format(abs(transaction.amount), code: currencyCode))"
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d MMM yyyy")
        return formatter.string(from: transaction.date)
    }

    private var iconName: String {
        switch transaction.category {
        case .salary:
            return "briefcase.fill"
        case .food:
            return "fork.knife"
        case .transport:
            return "car.fill"
        case .entertainment:
            return "sparkles"
        case .utilities:
            return "bolt.fill"
        case .shopping:
            return "bag.fill"
        case .health:
            return "heart.fill"
        case .other:
            return "tag.fill"
        }
    }

    private var badgeBackground: Color {
        transaction.type == .income ? Theme.incomeSoft : Theme.expenseSoft
    }

    private var badgeForeground: Color {
        transaction.type == .income ? Theme.income : Theme.expense
    }
}

#Preview {
    TransactionRowView(transaction: .sample)
        .padding()
        .background(Theme.background)
}
