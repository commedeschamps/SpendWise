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

    static func demoTransactions(referenceDate: Date = Date()) -> [Transaction] {
        let calendar = Calendar.current

        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: referenceDate) ?? referenceDate
        }

        let blueprint: [(String, Double, Int, TransactionType, Category, String, Bool)] = [
            ("Monthly Salary", 650_000, 2, .income, .salary, "Main job payroll", true),
            ("Freelance Design", 180_000, 9, .income, .salary, "Side project payout", false),
            ("Groceries", 18_500, 1, .expense, .food, "Weekly supermarket run", false),
            ("Coffee", 1_400, 0, .expense, .food, "Morning latte", false),
            ("Dinner", 15_000, 3, .expense, .food, "Dinner with friends", false),
            ("Fuel", 13_500, 4, .expense, .transport, "Car refill", false),
            ("Taxi", 4_500, 7, .expense, .transport, "Late ride home", false),
            ("Internet", 8_500, 6, .expense, .utilities, "Home internet", true),
            ("Electricity", 12_000, 12, .expense, .utilities, "Monthly bill", true),
            ("Streaming", 3_500, 11, .expense, .entertainment, "Video subscription", true),
            ("Cinema", 7_000, 8, .expense, .entertainment, "Weekend movie", false),
            ("Gym", 25_000, 5, .expense, .health, "Monthly membership", true),
            ("Pharmacy", 8_500, 10, .expense, .health, "Vitamins", false),
            ("Clothes", 42_000, 14, .expense, .shopping, "Seasonal sale", false),
            ("Gift", 20_000, 16, .expense, .other, "Birthday present", false),
            ("Bonus", 120_000, 20, .income, .salary, "Quarter bonus", false),
            ("Groceries", 16_200, 22, .expense, .food, "Market refill", false),
            ("Transit Pass", 9_000, 24, .expense, .transport, "Monthly metro pass", true),
            ("Water Bill", 4_500, 28, .expense, .utilities, "Utilities payment", true),
            ("Restaurant", 24_000, 30, .expense, .food, "Family dinner", false),
            ("Monthly Salary", 650_000, 33, .income, .salary, "Main job payroll", true),
            ("Online Shopping", 55_000, 36, .expense, .shopping, "Household items", false),
            ("Doctor Visit", 30_000, 39, .expense, .health, "Checkup", false),
            ("Concert Ticket", 35_000, 43, .expense, .entertainment, "Live concert", false)
        ]

        return blueprint.map { item in
            let date = daysAgo(item.2)
            return Transaction(
                id: UUID().uuidString,
                title: item.0,
                amount: item.1,
                date: date,
                type: item.3,
                category: item.4,
                note: item.5,
                isRecurring: item.6,
                createdAt: date
            )
        }
    }
}
