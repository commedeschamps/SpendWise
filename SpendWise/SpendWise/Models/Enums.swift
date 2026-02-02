import Foundation

enum TransactionType: String, CaseIterable, Codable, Identifiable {
    case income
    case expense

    var id: String { rawValue }

    var title: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        }
    }
}

enum Category: String, CaseIterable, Codable, Identifiable {
    case salary
    case food
    case transport
    case entertainment
    case utilities
    case shopping
    case health
    case other

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }
}

enum SortMode: String, CaseIterable, Identifiable {
    case dateDesc
    case dateAsc
    case amountDesc
    case amountAsc

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dateDesc: return "Date (Newest)"
        case .dateAsc: return "Date (Oldest)"
        case .amountDesc: return "Amount (High)"
        case .amountAsc: return "Amount (Low)"
        }
    }
}

enum FilterMode: String, CaseIterable, Identifiable {
    case all
    case income
    case expense
    case recurring

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .income: return "Income"
        case .expense: return "Expense"
        case .recurring: return "Recurring"
        }
    }
}
