import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @ObservedObject var tipsViewModel: TipsViewModel

    @AppStorage("currencyCode") private var currencyCode = "KZT"
    @AppStorage("monthlyBudget") private var monthlyBudget = 2000.0

    @State private var animatedProgress: Double = 0
    @State private var contentVisible = false

    var body: some View {
        ScrollView(showsIndicators: false) {
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
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SpendWise")
                        .font(Theme.largeTitleFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Your monthly money dashboard")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: Theme.spacing)
                Text(dateLabel)
                    .font(Theme.captionFont.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 11)
                    .background(Theme.elevatedBackground.opacity(0.75))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Theme.separator.opacity(0.22), lineWidth: 1)
                    )
            }

            HStack(spacing: Theme.compactSpacing) {
                Label(cycleLabel, systemImage: "calendar.badge.clock")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text(budgetStatus)
                    .font(Theme.captionFont.weight(.semibold))
                    .foregroundStyle(budgetStatusColor)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(budgetStatusColor.opacity(0.14))
                    .clipShape(Capsule())
            }
        }
        .cardStyle(background: Theme.heroGradient)
    }

    private var quickStats: some View {
        ScrollView(.horizontal, showsIndicators: false) {
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
                statChip(
                    title: "Budget Left",
                    value: Currency.format(budgetRemaining, code: currencyCode),
                    color: budgetRemaining > 0 ? Theme.income : Theme.expense
                )
            }
        }
    }

    private func statChip(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(Theme.captionFont.weight(.semibold))
                .foregroundStyle(color)
                .padding(.vertical, 3)
                .padding(.horizontal, 7)
                .background(color.opacity(0.14))
                .clipShape(Capsule())
                .lineLimit(1)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 11)
        .background(Theme.softCardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
    }

    private var budgetRemaining: Double {
        monthlyBudget - viewModel.expenseThisMonth
    }

    private var budgetStatus: String {
        guard monthlyBudget > 0 else { return "No limit" }
        if animatedProgress >= 1 { return "Over budget" }
        if animatedProgress >= 0.75 { return "Watch spending" }
        return "Healthy pace"
    }

    private var budgetStatusColor: Color {
        guard monthlyBudget > 0 else { return Theme.accentAlt }
        if animatedProgress >= 1 { return Theme.expense }
        if animatedProgress >= 0.75 { return Theme.accentAlt }
        return Theme.income
    }

    private var cycleLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return "\(formatter.string(from: Date())) cycle"
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
