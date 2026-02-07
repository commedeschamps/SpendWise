import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    @AppStorage("currencyCode") private var currencyCode = "KZT"

    var body: some View {
        HStack(alignment: .center, spacing: Theme.spacing) {
            iconBadge

            VStack(alignment: .leading, spacing: 6) {
                Text(transaction.title)
                    .font(Theme.subtitleFont)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                HStack(spacing: 6) {
                    categoryBadge
                    Text(dateString)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .layoutPriority(1)

            Spacer(minLength: Theme.compactSpacing)

            VStack(alignment: .trailing, spacing: 4) {
                Text(amountString)
                    .font(Theme.bodyFont.weight(.semibold))
                    .foregroundStyle(transaction.type == .income ? Theme.income : Theme.expense)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .allowsTightening(true)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        (transaction.type == .income ? Theme.incomeSoft : Theme.expenseSoft)
                            .opacity(0.9)
                    )
                    .clipShape(Capsule())
                if transaction.isRecurring {
                    Text("Recurring")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
            }
            .frame(minWidth: 110, maxWidth: 150, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(badgeBackground)
                .frame(width: 36, height: 36)
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
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
    }

    private var amountString: String {
        let sign = transaction.type == .expense ? "-" : "+"
        return "\(sign)\(Currency.format(abs(transaction.amount), code: currencyCode))"
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d MMM")
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
