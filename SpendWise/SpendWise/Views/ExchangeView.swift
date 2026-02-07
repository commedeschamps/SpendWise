import SwiftUI

struct ExchangeView: View {
    @AppStorage("currencyCode") private var currencyCode = "KZT"
    @StateObject private var viewModel = ExchangeViewModel()

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: Theme.compactSpacing) {
                    Text("Currency Exchange")
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Convert your amounts using live market rates.")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.clear)

            Section(
                header: Text("Converter"),
                footer: Text("Live exchange rates from ExchangeRate-API.")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            ) {
                TextField("Amount", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)

                Picker("From", selection: $viewModel.fromCode) {
                    ForEach(Currency.options) { option in
                        Text("\(option.code) - \(option.name)").tag(option.code)
                    }
                }

                Picker("To", selection: $viewModel.toCode) {
                    ForEach(Currency.options) { option in
                        Text("\(option.code) - \(option.name)").tag(option.code)
                    }
                }

                Button {
                    viewModel.swapCurrencies()
                } label: {
                    Label("Swap Currencies", systemImage: "arrow.up.arrow.down.circle")
                }
                .buttonStyle(.bordered)
                .tint(Theme.accentAlt)

                Button {
                    viewModel.convert()
                } label: {
                    Label("Convert", systemImage: "arrow.left.arrow.right.circle.fill")
                }
                .buttonStyle(PrimaryActionButtonStyle())

                if case .loading = viewModel.state {
                    HStack(spacing: Theme.compactSpacing) {
                        ProgressView()
                        Text("Converting...")
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                if viewModel.conversionResult != nil {
                    VStack(alignment: .leading, spacing: Theme.compactSpacing) {
                        Text("\(viewModel.formattedInput) = \(viewModel.formattedOutput)")
                        .font(Theme.subtitleFont)
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .monospacedDigit()
                        Text(viewModel.rateLine)
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.textSecondary)
                        if let lastUpdated = viewModel.lastUpdated {
                            Text("Updated \(relativeDateString(from: lastUpdated))")
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                if case .error(let message) = viewModel.state {
                    Text(message)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.expense)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .background {
            AppBackgroundView()
        }
        .navigationTitle("Exchange")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.syncFromPreferredCurrency(currencyCode)
        }
    }

    private func relativeDateString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationStack {
        ExchangeView()
    }
}
