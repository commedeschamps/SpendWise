import SwiftUI

struct SettingsView: View {
    @AppStorage("currencySymbol") private var currencySymbol = "$"
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
                    TextField("Currency Symbol", text: $currencySymbol)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    Stepper(value: $monthStartDay, in: 1...28) {
                        Text("Monthly Start Day: \(monthStartDay)")
                    }

                    TextField("Monthly Budget", value: $monthlyBudget, format: .number)
                        .keyboardType(.decimalPad)
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
    }
}

#Preview {
    SettingsView()
}
