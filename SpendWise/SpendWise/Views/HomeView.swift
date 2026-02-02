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
                Text("SpendWise")
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.top, Theme.spacing)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: Theme.spacing)], spacing: Theme.spacing) {
                    SummaryCardView(
                        title: "Balance",
                        amount: viewModel.balance,
                        currencySymbol: currencySymbol,
                        color: Theme.accent
                    )

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
            .padding(.bottom, Theme.spacing)
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

    private func updateProgress() {
        let progress = monthlyBudget > 0 ? min(viewModel.expenseThisMonth / monthlyBudget, 1) : 0
        withAnimation(.easeInOut(duration: 0.6)) {
            animatedProgress = progress
        }
    }
}

#Preview {
    HomeView(viewModel: TransactionViewModel(), tipsViewModel: TipsViewModel())
}
