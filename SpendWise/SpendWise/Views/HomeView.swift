import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @ObservedObject var tipsViewModel: TipsViewModel

    @AppStorage("currencySymbol") private var currencySymbol = "$"
    @AppStorage("monthlyBudget") private var monthlyBudget = 2000.0

    @State private var animatedProgress: Double = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing) {
                header

                SummaryCardView(
                    title: "Balance",
                    amount: viewModel.balance,
                    currencySymbol: currencySymbol,
                    color: Theme.accent,
                    isHero: true
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing) {
                    SummaryCardView(
                        title: "Income",
                        amount: viewModel.incomeThisMonth,
                        currencySymbol: currencySymbol,
                        color: Theme.income
                    )

                    SummaryCardView(
                        title: "Expenses",
                        amount: viewModel.expenseThisMonth,
                        currencySymbol: currencySymbol,
                        color: Theme.expense
                    )
                }

                BudgetCardView(
                    progress: animatedProgress,
                    spent: viewModel.expenseThisMonth,
                    budget: monthlyBudget,
                    currencySymbol: currencySymbol
                )

                TipsCardView(viewModel: tipsViewModel)
            }
            .padding(.horizontal, Theme.spacing)
            .padding(.vertical, Theme.spacing)
        }
        .background(Theme.background)
        .onAppear {
            updateProgress()
        }
        .onChange(of: viewModel.expenseThisMonth) { _ in
            updateProgress()
        }
        .onChange(of: monthlyBudget) { _ in
            updateProgress()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SpendWise")
                .font(Theme.titleFont)
                .foregroundStyle(Theme.textPrimary)
            Text("This month")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
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
