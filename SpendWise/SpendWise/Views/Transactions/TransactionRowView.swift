import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    @AppStorage("currencyCode") private var currencyCode = "KZT"

    var body: some View {
        HStack(alignment: .top, spacing: Theme.spacing) {
            VStack(alignment: .leading, spacing: 6) {
                Text(transaction.title)
                    .font(Theme.subtitleFont)
                    .foregroundStyle(Theme.textPrimary)

                HStack(spacing: 6) {
                    categoryBadge
                    Text(dateString)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            Spacer(minLength: Theme.compactSpacing)

            Text(amountString)
                .font(Theme.subtitleFont)
                .foregroundStyle(transaction.type == .income ? Theme.income : Theme.expense)
        }
        .padding(.vertical, 8)
    }

    private var categoryBadge: some View {
        Text(transaction.category.title)
            .font(Theme.captionFont)
            .foregroundStyle(Theme.textSecondary)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Theme.elevatedBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Theme.separator.opacity(0.4), lineWidth: 1)
            )
    }

    private var amountString: String {
        let sign = transaction.type == .expense ? "-" : "+"
        return "\(sign)\(Currency.format(abs(transaction.amount), code: currencyCode))"
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: transaction.date)
    }
}

#Preview {
    TransactionRowView(transaction: .sample)
        .padding()
        .background(Theme.background)
}
