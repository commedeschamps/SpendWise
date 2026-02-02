import SwiftUI

struct SettingsView: View {
    @AppStorage("currencySymbol") private var currencySymbol = "$"
    @AppStorage("monthStartDay") private var monthStartDay = 1
    @AppStorage("monthlyBudget") private var monthlyBudget = 2000.0

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    TextField("Currency Symbol", text: $currencySymbol)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    Stepper(value: $monthStartDay, in: 1...28) {
                        Text("Monthly Start Day: \(monthStartDay)")
                    }

                    TextField("Monthly Budget", value: $monthlyBudget, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Text("Settings are stored locally using UserDefaults.")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
