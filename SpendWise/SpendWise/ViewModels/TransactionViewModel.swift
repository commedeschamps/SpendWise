import Foundation
import Combine
import SwiftUI

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published private(set) var transactions: [Transaction] = []
    @Published var uiState: UIState = .idle
    @Published var lastSync: Date?
    @Published var filterMode: FilterMode = .all
    @Published var sortMode: SortMode = .dateDesc
    @Published var selectedCategory: Category? = nil

    private let repository: TransactionRepository
    private var isListening = false

    init(repository: TransactionRepository = FirebaseTransactionRepository()) {
        self.repository = repository
    }

    func startListening() {
        guard !isListening else { return }
        isListening = true
        uiState = .loading
        repository.listenTransactions { [weak self] result in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success(let items):
                    withAnimation(.spring()) {
                        self.transactions = items
                    }
                    self.lastSync = Date()
                    self.uiState = .success
                case .failure(let error):
                    self.uiState = .error(error.localizedDescription)
                }
            }
        }
    }

    func addTransaction(_ transaction: Transaction) {
        uiState = .loading
        repository.addTransaction(transaction) { [weak self] result in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success:
                    self.uiState = .success
                case .failure(let error):
                    self.uiState = .error(error.localizedDescription)
                }
            }
        }
    }

    func updateTransaction(_ transaction: Transaction) {
        uiState = .loading
        repository.updateTransaction(transaction) { [weak self] result in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success:
                    self.uiState = .success
                case .failure(let error):
                    self.uiState = .error(error.localizedDescription)
                }
            }
        }
    }

    func deleteTransaction(id: String) {
        uiState = .loading
        repository.deleteTransaction(id: id) { [weak self] result in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success:
                    self.uiState = .success
                case .failure(let error):
                    self.uiState = .error(error.localizedDescription)
                }
            }
        }
    }

    func toggleRecurring(for transaction: Transaction) {
        var updated = transaction
        updated.isRecurring.toggle()
        updateTransaction(updated)
    }

    var filteredTransactions: [Transaction] {
        let filtered = transactions
            .filter { transaction in
                switch filterMode {
                case .all:
                    return true
                case .income:
                    return transaction.type == .income
                case .expense:
                    return transaction.type == .expense
                case .recurring:
                    return transaction.isRecurring
                }
            }
            .filter { transaction in
                guard let selectedCategory else { return true }
                return transaction.category == selectedCategory
            }

        return filtered.sorted { lhs, rhs in
            switch sortMode {
            case .dateDesc:
                return lhs.date > rhs.date
            case .dateAsc:
                return lhs.date < rhs.date
            case .amountDesc:
                return lhs.amount > rhs.amount
            case .amountAsc:
                return lhs.amount < rhs.amount
            }
        }
    }

    var balance: Double {
        transactions.reduce(0) { total, transaction in
            total + (transaction.type == .income ? transaction.amount : -transaction.amount)
        }
    }

    var incomeThisMonth: Double {
        let range = currentCycleRange()
        return transactions
            .filter { $0.type == .income && $0.date >= range.start && $0.date < range.end }
            .map { $0.amount }
            .reduce(0, +)
    }

    var expenseThisMonth: Double {
        let range = currentCycleRange()
        return transactions
            .filter { $0.type == .expense && $0.date >= range.start && $0.date < range.end }
            .map { $0.amount }
            .reduce(0, +)
    }

    private func currentCycleRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startDay = max(1, min(28, UserDefaults.standard.integer(forKey: "monthStartDay").nonZeroOrDefault(1)))
        let today = Date()
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

private extension Int {
    func nonZeroOrDefault(_ fallback: Int) -> Int {
        self == 0 ? fallback : self
    }
}
