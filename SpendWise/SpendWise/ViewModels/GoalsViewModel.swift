import Foundation
import Combine
import SwiftUI

@MainActor
final class GoalsViewModel: ObservableObject {
    @Published private(set) var goals: [FinancialGoal] = []
    @Published var uiState: UIState = .idle

    private let storageKey = "SpendWiseGoals"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        loadGoals()
    }

    var sortedGoals: [FinancialGoal] {
        goals.sorted { lhs, rhs in
            if lhs.deadline == rhs.deadline {
                return lhs.createdAt < rhs.createdAt
            }
            return lhs.deadline < rhs.deadline
        }
    }

    var totalTargetAmount: Double {
        goals.map(\.targetAmount).reduce(0, +)
    }

    var totalSavedAmount: Double {
        goals.map(\.savedAmount).reduce(0, +)
    }

    var overallProgress: Double {
        guard totalTargetAmount > 0 else { return 0 }
        return min(totalSavedAmount / totalTargetAmount, 1)
    }

    func goal(withId id: String) -> FinancialGoal? {
        goals.first(where: { $0.id == id })
    }

    func addGoal(title: String, targetAmount: Double, savedAmount: Double, deadline: Date, note: String) {
        let goal = FinancialGoal(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            targetAmount: max(targetAmount, 0),
            savedAmount: max(savedAmount, 0),
            deadline: deadline,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date()
        )
        goals.append(goal)
        persist()
        uiState = .success
    }

    func updateGoal(_ goal: FinancialGoal) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[index] = goal
        persist()
        uiState = .success
    }

    func deleteGoal(id: String) {
        goals.removeAll { $0.id == id }
        persist()
        uiState = .success
    }

    func contribute(to goalId: String, amount: Double) {
        guard amount > 0,
              let index = goals.firstIndex(where: { $0.id == goalId }) else { return }
        goals[index].savedAmount += amount
        persist()
        uiState = .success
    }

    func daysRemaining(for goal: FinancialGoal) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: goal.deadline)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    func projection(for goal: FinancialGoal) -> GoalProjection {
        if goal.isCompleted {
            return GoalProjection(message: "Completed", isAtRisk: false)
        }

        let remaining = goal.remainingAmount
        let daysLeft = daysRemaining(for: goal)

        if goal.savedAmount <= 0 {
            if daysLeft < 0 {
                return GoalProjection(message: "Deadline passed", isAtRisk: true)
            }
            return GoalProjection(message: "No progress yet", isAtRisk: true)
        }

        let calendar = Calendar.current
        let elapsedDays = max(1, calendar.dateComponents([.day], from: goal.createdAt, to: Date()).day ?? 1)
        let dailyRate = goal.savedAmount / Double(elapsedDays)

        guard dailyRate > 0 else {
            return GoalProjection(message: "Need regular contributions", isAtRisk: true)
        }

        let neededDays = Int(ceil(remaining / dailyRate))
        let projectedDate = calendar.date(byAdding: .day, value: neededDays, to: Date()) ?? goal.deadline
        let dateText = Self.shortDateFormatter.string(from: projectedDate)

        if projectedDate <= goal.deadline {
            return GoalProjection(message: "On track: ~\(dateText)", isAtRisk: false)
        }
        return GoalProjection(message: "At risk: ~\(dateText)", isAtRisk: true)
    }

    private func loadGoals() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            goals = []
            return
        }
        do {
            goals = try decoder.decode([FinancialGoal].self, from: data)
        } catch {
            goals = []
            uiState = .error("Failed to load goals.")
        }
    }

    private func persist() {
        do {
            let data = try encoder.encode(goals)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            uiState = .error("Failed to save goals.")
        }
    }

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

struct GoalProjection {
    let message: String
    let isAtRisk: Bool
}
