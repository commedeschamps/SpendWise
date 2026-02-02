import SwiftUI

struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingAddForm = false
    @State private var showSyncBanner = false

    var body: some View {
        VStack(spacing: Theme.compactSpacing) {
            filterBar

            if showSyncBanner, let lastSync = viewModel.lastSync {
                syncBanner(date: lastSync)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            List {
                if case .loading = viewModel.uiState {
                    Section {
                        ProgressView("Syncing transactions...")
                    }
                }

                if case .error(let message) = viewModel.uiState {
                    Section {
                        Text(message)
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.expense)
                    }
                }

                if overdueTransactions.isEmpty && upcomingThisMonth.isEmpty && olderTransactions.isEmpty {
                    Text("No transactions yet.")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    section(title: "Overdue", items: overdueTransactions)
                    section(title: "This Month", items: upcomingThisMonth)
                    section(title: "Older", items: olderTransactions)
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Transactions")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddForm = true
                } label: {
                    Image(systemName: "plus")
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
            .background(Theme.cardBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Theme.separator.opacity(0.2), lineWidth: 1)
            )
    }

    private func section(title: String, items: [Transaction]) -> some View {
        guard !items.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            Section(header: Text(title)) {
                ForEach(items) { transaction in
                    NavigationLink {
                        TransactionDetailView(transaction: transaction, viewModel: viewModel)
                    } label: {
                        TransactionRowView(transaction: transaction)
                    }
                }
                .onDelete { offsets in
                    delete(offsets, in: items)
                }
            }
        )
    }

    private func delete(_ offsets: IndexSet, in items: [Transaction]) {
        for index in offsets {
            viewModel.deleteTransaction(id: items[index].id)
        }
    }

    private var overdueTransactions: [Transaction] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else { return [] }
        let today = calendar.startOfDay(for: Date())

        return viewModel.filteredTransactions
            .filter { $0.date >= monthInterval.start && $0.date < today }
    }

    private var upcomingThisMonth: [Transaction] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else { return [] }
        let today = calendar.startOfDay(for: Date())

        return viewModel.filteredTransactions
            .filter { $0.date >= today && $0.date < monthInterval.end }
    }

    private var olderTransactions: [Transaction] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else { return [] }

        return viewModel.filteredTransactions
            .filter { $0.date < monthInterval.start }
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
        .background(Theme.cardBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Theme.separator.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, Theme.spacing)
    }

    private func relativeDateString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationStack {
        TransactionListView(viewModel: TransactionViewModel())
    }
}
