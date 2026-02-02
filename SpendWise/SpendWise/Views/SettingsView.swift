import SwiftUI

struct SettingsView: View {
    @AppStorage("currencyCode") private var currencyCode = "KZT"
    @AppStorage("monthStartDay") private var monthStartDay = 1
    @AppStorage("monthlyBudget") private var monthlyBudget = 2000.0

    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("Preferences"),
                    footer: Text("These settings are stored locally on this device.")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                ) {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(Currency.options) { option in
                            Text("\(option.code) - \(option.name)").tag(option.code)
                        }
                    }

                    Stepper(value: $monthStartDay, in: 1...28) {
                        Text("Monthly Start Day: \(monthStartDay)")
                    }

                    TextField("Monthly Budget", value: $monthlyBudget, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section(
                    header: Text("Category Budgets"),
                    footer: Text("Set a limit per category. Use 0 to disable.")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                ) {
                    ForEach(Category.allCases) { category in
                        HStack {
                            Text(category.title)
                                .font(Theme.bodyFont)
                            Spacer()
                            TextField("0", value: CategoryBudgetStore.binding(for: category), format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 110)
                            Text(Currency.symbol(for: currencyCode))
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }

                Section(
                    footer: Text("Tip: set a realistic budget to see accurate usage in Home.")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear(perform: migrateLegacyCurrency)
    }

    private func migrateLegacyCurrency() {
        guard currencyCode.isEmpty,
              let legacySymbol = UserDefaults.standard.string(forKey: "currencySymbol") else {
            return
        }
        if let mapped = Currency.code(fromSymbol: legacySymbol) {
            currencyCode = mapped
        }
    }
}

#Preview {
    SettingsView()
}
