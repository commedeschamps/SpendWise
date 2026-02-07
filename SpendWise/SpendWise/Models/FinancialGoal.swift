import Foundation

struct FinancialGoal: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var targetAmount: Double
    var savedAmount: Double
    var deadline: Date
    var note: String
    let createdAt: Date

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(savedAmount / targetAmount, 1)
    }

    var remainingAmount: Double {
        max(targetAmount - savedAmount, 0)
    }

    var isCompleted: Bool {
        savedAmount >= targetAmount
    }
}
