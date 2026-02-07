import Foundation
import Combine
import SwiftUI

@MainActor
final class ExchangeViewModel: ObservableObject {
    @Published var amountText = "1000"
    @Published var fromCode = "KZT"
    @Published var toCode = "USD"
    @Published var state: UIState = .idle
    @Published var conversionResult: CurrencyConversion?
    @Published var lastUpdated: Date?

    private let exchangeService: TipsAPIService

    init(exchangeService: TipsAPIService = TipsAPIService()) {
        self.exchangeService = exchangeService
    }

    func syncFromPreferredCurrency(_ currencyCode: String) {
        if Currency.options.contains(where: { $0.code == currencyCode }) {
            fromCode = currencyCode
        }
    }

    func swapCurrencies() {
        let previousFrom = fromCode
        fromCode = toCode
        toCode = previousFrom
    }

    func convert() {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(normalized), amount >= 0 else {
            state = .error("Enter a valid non-negative amount.")
            return
        }

        state = .loading
        Task {
            do {
                let conversion = try await exchangeService.convert(
                    amount: amount,
                    from: fromCode,
                    to: toCode
                )
                conversionResult = conversion
                lastUpdated = Date()
                state = .success
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    var formattedInput: String {
        guard let conversionResult else { return "" }
        return Currency.format(conversionResult.inputAmount, code: conversionResult.sourceCode)
    }

    var formattedOutput: String {
        guard let conversionResult else { return "" }
        return Currency.format(conversionResult.outputAmount, code: conversionResult.targetCode)
    }

    var rateLine: String {
        guard let conversionResult else { return "" }
        return "1 \(conversionResult.sourceCode) = \(String(format: "%.4f", conversionResult.rate)) \(conversionResult.targetCode)"
    }
}
