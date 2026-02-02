import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel: TransactionViewModel

    @AppStorage("currencyCode") private var currencyCode = "KZT"
    @AppStorage("monthStartDay") private var monthStartDay = 1

    @State private var period: AnalyticsPeriod = .month

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing) {
                header

                summaryCard

                categoryBreakdownCard

                recentActivityCard
            }
            .padding(.horizontal, Theme.spacing)
            .padding(.vertical, Theme.spacing)
        }
        .background(Theme.background)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Analytics")
                .font(Theme.largeTitleFont)
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 12) {
                Text(period.title)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)

                Spacer()

                Picker("Period", selection: $period) {
                    ForEach(AnalyticsPeriod.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 240)
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text("Summary")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: Theme.spacing) {
                summaryMetric(title: "Income", value: incomeForPeriod, color: Theme.income)
                summaryMetric(title: "Expenses", value: expenseForPeriod, color: Theme.expense)
                summaryMetric(title: "Balance", value: balanceForPeriod, color: Theme.accent)
            }
        }
        .cardStyle()
    }

    private func summaryMetric(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
            Text(Currency.format(value, code: currencyCode))
                .font(Theme.amountFont)
                .foregroundStyle(color)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text("Spending by Category")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)

            if expenseTotals.isEmpty {
                Text("No expenses yet for this period.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                ForEach(expenseTotals) { item in
                    CategoryBarRow(
                        category: item.category.title,
                        amount: item.total,
                        budget: CategoryBudgetStore.budget(for: item.category),
                        maxAmount: maxExpenseTotal,
                        currencyCode: currencyCode
                    )
                }
            }
        }
        .cardStyle()
    }

    private var recentActivityCard: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text("Recent Activity")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)

            if recentTransactions.isEmpty {
                Text("No recent transactions.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                ForEach(recentTransactions) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.title)
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.textPrimary)
                            Text(transaction.category.title)
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        Text(formattedSignedAmount(transaction))
                            .font(Theme.bodyFont.weight(.semibold))
                            .foregroundStyle(transaction.type == .income ? Theme.income : Theme.expense)
                    }
                    if transaction.id != recentTransactions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .cardStyle()
    }

    private var transactionsInPeriod: [Transaction] {
        let range = dateRange(for: period)
        return viewModel.transactions.filter { $0.date >= range.start && $0.date < range.end }
    }

    private var incomeForPeriod: Double {
        transactionsInPeriod
            .filter { $0.type == .income }
            .map { $0.amount }
            .reduce(0, +)
    }

    private var expenseForPeriod: Double {
        transactionsInPeriod
            .filter { $0.type == .expense }
            .map { $0.amount }
            .reduce(0, +)
    }

    private var balanceForPeriod: Double {
        incomeForPeriod - expenseForPeriod
    }

    private var expenseTotals: [CategoryTotal] {
        let range = dateRange(for: period)
        return Category.allCases.map { category in
            let total = viewModel.transactions
                .filter { $0.type == .expense && $0.category == category && $0.date >= range.start && $0.date < range.end }
                .map { $0.amount }
                .reduce(0, +)
            return CategoryTotal(category: category, total: total)
        }
        .filter { $0.total > 0 }
        .sorted { $0.total > $1.total }
    }

    private var maxExpenseTotal: Double {
        expenseTotals.map { $0.total }.max() ?? 0
    }

    private var recentTransactions: [Transaction] {
        Array(viewModel.transactions.sorted { $0.date > $1.date }.prefix(3))
    }

    private func formattedSignedAmount(_ transaction: Transaction) -> String {
        let sign = transaction.type == .expense ? "-" : "+"
        return "\(sign)\(Currency.format(abs(transaction.amount), code: currencyCode))"
    }

    private func dateRange(for period: AnalyticsPeriod) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = Date()

        switch period {
        case .week:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? calendar.startOfDay(for: today)
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? today
            return (weekStart, weekEnd)
        case .month:
            return customMonthRange(today: today)
        case .year:
            let yearStart = calendar.dateInterval(of: .year, for: today)?.start ?? calendar.startOfDay(for: today)
            let yearEnd = calendar.date(byAdding: .year, value: 1, to: yearStart) ?? today
            return (yearStart, yearEnd)
        }
    }

    private func customMonthRange(today: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startDay = max(1, min(28, monthStartDay))
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        guard let day = components.day,
              let month = components.month,
              let year = components.year else {
            let start = calendar.startOfDay(for: today)
            return (start, calendar.date(byAdding: .month, value: 1, to: start) ?? today)
        }

        var startComponents = DateComponents(year: year, month: month, day: startDay)
        if day < startDay {
            if let previous = calendar.date(byAdding: .month, value: -1, to: today) {
                let previousComponents = calendar.dateComponents([.year, .month], from: previous)
                startComponents.year = previousComponents.year
                startComponents.month = previousComponents.month
            }
        }

        let startDate = calendar.date(from: startComponents) ?? calendar.startOfDay(for: today)
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) ?? today
        return (startDate, endDate)
    }
}

private struct CategoryTotal: Identifiable {
    let id = UUID().uuidString
    let category: Category
    let total: Double
}

private struct CategoryBarRow: View {
    let category: String
    let amount: Double
    let budget: Double
    let maxAmount: Double
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(category)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(amountLabel)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.separator.opacity(0.15))
                    Capsule()
                        .fill(barColor)
                        .frame(width: proxy.size.width * CGFloat(progress))
                }
            }
            .frame(height: 8)
            .animation(.easeInOut(duration: 0.3), value: amount)

            if budget > 0 && amount > budget {
                Text("Over budget")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.expense)
            }
        }
    }

    private var progress: Double {
        if budget > 0 {
            return min(amount / budget, 1)
        }
        guard maxAmount > 0 else { return 0 }
        return min(amount / maxAmount, 1)
    }

    private var barColor: Color {
        budget > 0 && amount > budget ? Theme.expense : Theme.accent
    }

    private var amountLabel: String {
        if budget > 0 {
            return "\(Currency.format(amount, code: currencyCode)) / \(Currency.format(budget, code: currencyCode))"
        }
        return Currency.format(amount, code: currencyCode)
    }
}

private enum AnalyticsPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }
}

#Preview {
    AnalyticsView(viewModel: TransactionViewModel())
}
