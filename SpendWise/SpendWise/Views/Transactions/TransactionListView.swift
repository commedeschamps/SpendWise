import SwiftUI

struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @AppStorage("currencyCode") private var currencyCode = "KZT"
    @State private var showingAddForm = false
    @State private var showSyncBanner = false
    @State private var searchText = ""
    @State private var dateScope: TransactionDateScope = .all

    var body: some View {
        VStack(spacing: Theme.compactSpacing) {
            filterBar
            overviewBar

            if showSyncBanner, let lastSync = viewModel.lastSync {
                syncBanner(date: lastSync)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            List {
                if case .loading = viewModel.uiState {
                    Section {
                        ProgressView("Syncing transactions...")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }

                if case .error(let message) = viewModel.uiState {
                    Section {
                        Text(message)
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.expense)
                    }
                }

                if overdueTransactions.isEmpty &&
                    upcomingThisCycle.isEmpty &&
                    futureTransactions.isEmpty &&
                    olderTransactions.isEmpty {
                    Text("No transactions yet.")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    section(title: "Overdue", items: overdueTransactions)
                    section(title: "This Cycle", items: upcomingThisCycle)
                    section(title: "Future", items: futureTransactions)
                    section(title: "Older", items: olderTransactions)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .background {
            AppBackgroundView()
        }
        .navigationTitle("Transactions")
        .searchable(text: $searchText, prompt: "Search title, note, category")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddForm = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Theme.accent, in: Circle())
                        .shadow(color: Theme.accent.opacity(0.35), radius: 6, x: 0, y: 3)
                }
            }
        }
        .sheet(isPresented: $showingAddForm) {
            TransactionFormView(isPresented: $showingAddForm) { transaction in
                viewModel.addTransaction(transaction)
            }
        }
        .onChange(of: viewModel.uiState) { state in
            if case .success = state {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSyncBanner = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSyncBanner = false
                    }
                }
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.compactSpacing) {
                Menu {
                    Picker("Filter", selection: $viewModel.filterMode) {
                        ForEach(FilterMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                } label: {
                    chipLabel(title: viewModel.filterMode.title, systemImage: "line.3.horizontal.decrease.circle")
                }

                Menu {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("All Categories").tag(Category?.none)
                        ForEach(Category.allCases) { category in
                            Text(category.title).tag(Optional(category))
                        }
                    }
                } label: {
                    chipLabel(title: viewModel.selectedCategory?.title ?? "All Categories", systemImage: "tag")
                }

                Menu {
                    Picker("Sort", selection: $viewModel.sortMode) {
                        ForEach(SortMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                } label: {
                    chipLabel(title: viewModel.sortMode.title, systemImage: "arrow.up.arrow.down")
                }

                Menu {
                    Picker("Period", selection: $dateScope) {
                        ForEach(TransactionDateScope.allCases) { scope in
                            Text(scope.title).tag(scope)
                        }
                    }
                } label: {
                    chipLabel(title: dateScope.title, systemImage: "calendar")
                }
            }
            .padding(.horizontal, Theme.spacing)
            .padding(.vertical, Theme.compactSpacing)
        }
    }

    private func chipLabel(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(Theme.captionFont)
            .foregroundStyle(Theme.textPrimary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Theme.elevatedBackground.opacity(0.8))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Theme.accent.opacity(0.18), lineWidth: 1)
            )
    }

    private var overviewBar: some View {
        HStack(spacing: Theme.compactSpacing) {
            overviewChip(title: "Items", value: "\(displayTransactions.count)", color: Theme.accent)
            overviewChip(title: "Income", value: currencyAmount(filteredIncome), color: Theme.income)
            overviewChip(title: "Expense", value: currencyAmount(filteredExpense), color: Theme.expense)
        }
        .padding(.horizontal, Theme.spacing)
    }

    private func overviewChip(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(Theme.captionFont.weight(.semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(Theme.elevatedBackground.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.22), lineWidth: 1)
        )
    }

    private func section(title: String, items: [Transaction]) -> some View {
        guard !items.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            Section(header: Text(title.uppercased()).font(Theme.captionFont).foregroundStyle(Theme.textSecondary)) {
                ForEach(items) { transaction in
                    row(for: transaction)
                }
                .onDelete { offsets in
                    delete(offsets, in: items)
                }
            }
        )
    }

    private func row(for transaction: Transaction) -> some View {
        NavigationLink {
            TransactionDetailView(transaction: transaction, viewModel: viewModel)
        } label: {
            TransactionRowView(transaction: transaction)
        }
        .listRowBackground(Theme.cardBackground)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                viewModel.toggleRecurring(for: transaction)
            } label: {
                Label(transaction.isRecurring ? "Unmark Recurring" : "Recurring", systemImage: "arrow.triangle.2.circlepath")
            }
            .tint(Theme.accentAlt)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.deleteTransaction(id: transaction.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                viewModel.duplicateTransaction(transaction)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            .tint(Theme.accent)
        }
    }

    private func delete(_ offsets: IndexSet, in items: [Transaction]) {
        for index in offsets {
            viewModel.deleteTransaction(id: items[index].id)
        }
    }

    private var overdueTransactions: [Transaction] {
        let calendar = Calendar.current
        let range = viewModel.currentCycleRange
        let cycleStart = range.start
        let today = calendar.startOfDay(for: Date())

        return displayTransactions
            .filter { $0.date >= cycleStart && $0.date < today }
    }

    private func matchesSearch(_ transaction: Transaction) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        let haystack = "\(transaction.title) \(transaction.note) \(transaction.category.title)".lowercased()
        return haystack.contains(query.lowercased())
    }

    private func matchesDateScope(_ transaction: Transaction) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        switch dateScope {
        case .all:
            return true
        case .currentCycle:
            let range = viewModel.currentCycleRange
            return transaction.date >= range.start && transaction.date < range.end
        case .last7Days:
            guard let start = calendar.date(byAdding: .day, value: -6, to: today) else { return true }
            return transaction.date >= start && transaction.date <= Date()
        case .last30Days:
            guard let start = calendar.date(byAdding: .day, value: -29, to: today) else { return true }
            return transaction.date >= start && transaction.date <= Date()
        }
    }

    private var displayTransactions: [Transaction] {
        viewModel.filteredTransactions
            .filter(matchesSearch)
            .filter(matchesDateScope)
    }

    private var upcomingThisCycle: [Transaction] {
        let calendar = Calendar.current
        let range = viewModel.currentCycleRange
        let cycleEnd = range.end
        let today = calendar.startOfDay(for: Date())

        return displayTransactions
            .filter { $0.date >= today && $0.date < cycleEnd }
    }

    private var futureTransactions: [Transaction] {
        let cycleEnd = viewModel.currentCycleRange.end
        return displayTransactions
            .filter { $0.date >= cycleEnd }
    }

    private var olderTransactions: [Transaction] {
        let cycleStart = viewModel.currentCycleRange.start

        return displayTransactions
            .filter { $0.date < cycleStart }
    }

    private func syncBanner(date: Date) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.income)
            Text("Synced \(relativeDateString(from: date))")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
        }
        .padding(.horizontal, Theme.spacing)
        .padding(.vertical, Theme.compactSpacing)
        .background(Theme.heroGradient)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Theme.separator.opacity(0.24), lineWidth: 1)
        )
        .padding(.horizontal, Theme.spacing)
    }

    private func relativeDateString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private var filteredIncome: Double {
        displayTransactions
            .filter { $0.type == .income }
            .map { $0.amount }
            .reduce(0, +)
    }

    private var filteredExpense: Double {
        displayTransactions
            .filter { $0.type == .expense }
            .map { $0.amount }
            .reduce(0, +)
    }

    private func currencyAmount(_ amount: Double) -> String {
        Currency.format(amount, code: currencyCode)
    }
}

private enum TransactionDateScope: String, CaseIterable, Identifiable {
    case all
    case currentCycle
    case last7Days
    case last30Days

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All Time"
        case .currentCycle: return "This Cycle"
        case .last7Days: return "Last 7 Days"
        case .last30Days: return "Last 30 Days"
        }
    }
}

#Preview {
    NavigationStack {
        TransactionListView(viewModel: TransactionViewModel())
    }
}
