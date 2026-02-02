import Foundation

struct Transaction: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var amount: Double
    var date: Date
    var type: TransactionType
    var category: Category
    var note: String
    var isRecurring: Bool
    var createdAt: Date
}

extension Transaction {
    static let sample = Transaction(
        id: UUID().uuidString,
        title: "Groceries",
        amount: 54.25,
        date: Date(),
        type: .expense,
        category: .food,
        note: "Weekly groceries",
        isRecurring: false,
        createdAt: Date()
    )
}
