import SwiftUI

struct SettingsView: View {
    @AppStorage("currencyCode") private var currencyCode = "KZT"
    @AppStorage("monthStartDay") private var monthStartDay = 1
    @AppStorage("monthlyBudget") private var monthlyBudget = 2000.0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Theme.accentSoft)
                                .frame(width: 34, height: 34)
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.accent)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Workspace Settings")
                                .font(Theme.titleFont)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Personalize currency, budget cycle and category limits.")
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.clear)

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

                    HStack {
                        TextField("Monthly Budget", value: $monthlyBudget, format: .number)
                            .keyboardType(.decimalPad)
                        Text(currencyCode)
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.textSecondary)
                    }
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
                            Text(currencyCode)
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
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background {
            AppBackgroundView()
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
