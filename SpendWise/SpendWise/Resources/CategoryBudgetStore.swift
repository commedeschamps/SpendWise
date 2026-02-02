import Foundation
import SwiftUI

struct CategoryBudgetStore {
    private static let prefix = "categoryBudget_"

    static func budget(for category: Category) -> Double {
        UserDefaults.standard.double(forKey: key(for: category))
    }

    static func setBudget(_ value: Double, for category: Category) {
        UserDefaults.standard.set(value, forKey: key(for: category))
    }

    static func binding(for category: Category) -> Binding<Double> {
        Binding(
            get: {
                budget(for: category)
            },
            set: { newValue in
                setBudget(newValue, for: category)
            }
        )
    }

    private static func key(for category: Category) -> String {
        prefix + category.rawValue
    }
}
