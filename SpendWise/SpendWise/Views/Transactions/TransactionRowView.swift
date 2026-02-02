import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    @AppStorage("currencySymbol") private var currencySymbol = "$"

    var body: some View {
        HStack(spacing: Theme.spacing) {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(Theme.subtitleFont)
                    .foregroundStyle(Theme.textPrimary)
                Text("\(transaction.category.title) - \(dateString)")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            Text(amountString)
                .font(Theme.subtitleFont)
                .foregroundStyle(transaction.type == .income ? Theme.income : Theme.expense)
        }
        .padding(.vertical, 4)
    }

    private var amountString: String {
        let sign = transaction.type == .expense ? "-" : "+"
        return "\(sign)\(currencySymbol)\(String(format: "%.2f", transaction.amount))"
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
