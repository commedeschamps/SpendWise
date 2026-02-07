import SwiftUI

struct SettingsView: View {
    @ObservedObject var transactionsViewModel: TransactionViewModel
    @AppStorage("currencyCode") private var currencyCode = "KZT"
    @AppStorage("monthStartDay") private var monthStartDay = 1
    @AppStorage("monthlyBudget") private var monthlyBudget = 2000.0
    @State private var isRunningDemoAction = false
    @State private var showLoadDemoConfirmation = false
    @State private var showClearConfirmation = false
    @State private var resultMessage = ""
    @State private var showResultAlert = false

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
                    header: Text("Demo Data"),
                    footer: Text("Use for presentation and QA. Demo load replaces current transactions.")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                ) {
                    Button {
                        showLoadDemoConfirmation = true
                    } label: {
                        HStack {
                            Label("Load Demo Transactions", systemImage: "wand.and.stars")
                            Spacer()
                            if isRunningDemoAction {
                                ProgressView()
                                    .scaleEffect(0.85)
                            }
                        }
                    }
                    .disabled(isRunningDemoAction)

                    Button(role: .destructive) {
                        showClearConfirmation = true
                    } label: {
                        Label("Clear All Transactions", systemImage: "trash")
                    }
                    .disabled(isRunningDemoAction || transactionsViewModel.transactions.isEmpty)
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
        .confirmationDialog(
            "Replace current transactions?",
            isPresented: $showLoadDemoConfirmation,
            titleVisibility: .visible
        ) {
            Button("Replace and Load", role: .destructive, action: loadDemoData)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove current transactions and add a demo set.")
        }
        .confirmationDialog(
            "Delete all transactions?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete All", role: .destructive, action: clearAllData)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Demo Data", isPresented: $showResultAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(resultMessage)
        }
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

    private func loadDemoData() {
        isRunningDemoAction = true
        Task { @MainActor in
            let result = await transactionsViewModel.seedDemoTransactions(replaceExisting: true)
            isRunningDemoAction = false
            switch result {
            case .success(let count):
                presentResult("Loaded \(count) demo transactions.")
            case .failure(let error):
                presentResult("Failed to load demo data: \(error.localizedDescription)")
            }
        }
    }

    private func clearAllData() {
        isRunningDemoAction = true
        Task { @MainActor in
            let result = await transactionsViewModel.clearAllTransactions()
            isRunningDemoAction = false
            switch result {
            case .success(let count):
                presentResult("Deleted \(count) transactions.")
            case .failure(let error):
                presentResult("Failed to clear transactions: \(error.localizedDescription)")
            }
        }
    }

    private func presentResult(_ message: String) {
        resultMessage = message
        showResultAlert = true
    }
}

#Preview {
    SettingsView(transactionsViewModel: TransactionViewModel())
}
