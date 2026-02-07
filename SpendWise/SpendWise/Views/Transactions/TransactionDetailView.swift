import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @ObservedObject var viewModel: TransactionViewModel

    @AppStorage("currencyCode") private var currencyCode = "KZT"
    @State private var showingEditForm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing) {
                amountHero
                detailCard

                Button {
                    viewModel.toggleRecurring(for: currentTransaction)
                } label: {
                    Label(
                        currentTransaction.isRecurring ? "Turn Off Recurring" : "Set as Recurring",
                        systemImage: currentTransaction.isRecurring ? "arrow.triangle.2.circlepath" : "arrow.triangle.2.circlepath.circle"
                    )
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
            .padding(Theme.spacing)
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditForm = true
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                        .font(Theme.captionFont)
                }
            }
        }
        .sheet(isPresented: $showingEditForm) {
            TransactionFormView(isPresented: $showingEditForm, existing: currentTransaction) { updated in
                viewModel.updateTransaction(updated)
            }
        }
        .background {
            AppBackgroundView()
        }
    }

    private var amountHero: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            HStack {
                Text(currentTransaction.type.title)
                    .font(Theme.captionFont)
                    .foregroundStyle(currentTransaction.type == .income ? Theme.income : Theme.expense)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background((currentTransaction.type == .income ? Theme.incomeSoft : Theme.expenseSoft).opacity(0.9))
                    .clipShape(Capsule())
                Spacer()
                Text(dateString)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }

            Text(formattedSignedAmount(currentTransaction))
                .font(Theme.heroAmountFont)
                .foregroundStyle(currentTransaction.type == .income ? Theme.income : Theme.expense)
                .monospacedDigit()

            Text(currentTransaction.title)
                .font(Theme.subtitleFont)
                .foregroundStyle(Theme.textPrimary)
        }
        .cardStyle(background: Theme.heroGradient)
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transaction Info")
                        .font(Theme.subtitleFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text(currentTransaction.category.title)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
            }

            Divider()

            detailRow(label: "Amount", value: Currency.format(currentTransaction.amount, code: currencyCode), isAccent: true)
            detailRow(label: "Recurring", value: currentTransaction.isRecurring ? "Yes" : "No")
            detailRow(label: "Created", value: createdDateString)

            if !currentTransaction.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Divider()
                Text("Notes")
                    .font(Theme.subtitleFont)
                Text(currentTransaction.note)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .cardStyle()
    }

    private func detailRow(label: String, value: String, isAccent: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.bodyFont.weight(.semibold))
                .foregroundStyle(isAccent ? Theme.accent : Theme.textPrimary)
        }
    }

    private var currentTransaction: Transaction {
        viewModel.transactions.first(where: { $0.id == transaction.id }) ?? transaction
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: currentTransaction.date)
    }

    private var createdDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: currentTransaction.createdAt)
    }

    private func formattedSignedAmount(_ transaction: Transaction) -> String {
        let sign = transaction.type == .expense ? "-" : "+"
        return "\(sign)\(Currency.format(abs(transaction.amount), code: currencyCode))"
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(transaction: .sample, viewModel: TransactionViewModel())
    }
}
