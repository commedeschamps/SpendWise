import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @ObservedObject var viewModel: TransactionViewModel

    @AppStorage("currencyCode") private var currencyCode = "KZT"
    @State private var showingEditForm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing) {
                detailCard

                Button {
                    viewModel.toggleRecurring(for: currentTransaction)
                } label: {
                    Label(
                        currentTransaction.isRecurring ? "Recurring" : "Not Recurring",
                        systemImage: currentTransaction.isRecurring ? "arrow.triangle.2.circlepath" : "arrow.triangle.2.circlepath.circle"
                    )
                    .font(Theme.subtitleFont)
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.compactSpacing)
                }
                .cardStyle(background: Theme.elevatedBackground)
            }
            .padding(Theme.spacing)
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditForm = true
                }
            }
        }
        .sheet(isPresented: $showingEditForm) {
            TransactionFormView(isPresented: $showingEditForm, existing: currentTransaction) { updated in
                viewModel.updateTransaction(updated)
            }
        }
        .background(Theme.background)
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentTransaction.title)
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text("\(currentTransaction.category.title) - \(dateString)")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Text(currentTransaction.type.title)
                    .font(Theme.captionFont.weight(.semibold))
                    .foregroundStyle(currentTransaction.type == .income ? Theme.income : Theme.expense)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(currentTransaction.type == .income ? Theme.incomeSoft : Theme.expenseSoft)
                    .clipShape(Capsule())
            }

            Divider()

            detailRow(label: "Amount", value: Currency.format(currentTransaction.amount, code: currencyCode))
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

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.bodyFont.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
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
}

#Preview {
    NavigationStack {
        TransactionDetailView(transaction: .sample, viewModel: TransactionViewModel())
    }
}
