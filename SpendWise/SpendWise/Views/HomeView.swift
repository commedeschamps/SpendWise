import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @ObservedObject var tipsViewModel: TipsViewModel

    @AppStorage("currencyCode") private var currencyCode = "KZT"
    @AppStorage("monthlyBudget") private var monthlyBudget = 2000.0

    @State private var animatedProgress: Double = 0
    @State private var contentVisible = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing) {
                header
                quickStats

                SummaryCardView(
                    title: "Balance",
                    amount: viewModel.balance,
                    currencyCode: currencyCode,
                    color: Theme.accent,
                    isHero: true
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing) {
                    SummaryCardView(
                        title: "Income",
                        amount: viewModel.incomeThisMonth,
                        currencyCode: currencyCode,
                        color: Theme.income
                    )

                    SummaryCardView(
                        title: "Expenses",
                        amount: viewModel.expenseThisMonth,
                        currencyCode: currencyCode,
                        color: Theme.expense
                    )
                }

                BudgetCardView(
                    progress: animatedProgress,
                    spent: viewModel.expenseThisMonth,
                    budget: monthlyBudget,
                    currencyCode: currencyCode
                )

                TipsCardView(viewModel: tipsViewModel)
            }
            .padding(.horizontal, Theme.spacing)
            .padding(.vertical, Theme.spacing)
            .opacity(contentVisible ? 1 : 0)
            .offset(y: contentVisible ? 0 : 12)
            .animation(.easeOut(duration: 0.35), value: contentVisible)
        }
        .background {
            AppBackgroundView()
        }
        .onAppear {
            updateProgress()
            contentVisible = true
        }
        .onChange(of: viewModel.expenseThisMonth) { _ in
            updateProgress()
        }
        .onChange(of: monthlyBudget) { _ in
            updateProgress()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("SpendWise")
                        .font(Theme.largeTitleFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text("This month")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Text(dateLabel)
                    .font(Theme.captionFont.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Theme.elevatedBackground.opacity(0.8))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Theme.separator.opacity(0.24), lineWidth: 1)
                    )
            }

            Text("Track budget and spending in one glance.")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var quickStats: some View {
        HStack(spacing: Theme.compactSpacing) {
            statChip(
                title: "Transactions",
                value: "\(viewModel.transactions.count)",
                color: Theme.accent
            )
            statChip(
                title: "Recurring",
                value: "\(viewModel.transactions.filter { $0.isRecurring }.count)",
                color: Theme.accentAlt
            )
        }
    }

    private func statChip(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(Theme.captionFont)
                .foregroundStyle(color)
                .padding(.vertical, 3)
                .padding(.horizontal, 7)
                .background(color.opacity(0.14))
                .clipShape(Capsule())
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(Theme.elevatedBackground.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: Date())
    }

    private func updateProgress() {
        let progress = monthlyBudget > 0 ? min(viewModel.expenseThisMonth / monthlyBudget, 1) : 0
        withAnimation(.easeInOut(duration: 0.35)) {
            animatedProgress = progress
        }
    }
}

#Preview {
    HomeView(viewModel: TransactionViewModel(), tipsViewModel: TipsViewModel())
}
