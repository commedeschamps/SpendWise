import Foundation

struct CurrencyOption: Identifiable, Equatable {
    let code: String
    let name: String
    let symbol: String

    var id: String { code }
}

enum Currency {
    static let options: [CurrencyOption] = [
        CurrencyOption(code: "KZT", name: "Kazakhstani Tenge", symbol: "KZT"),
        CurrencyOption(code: "USD", name: "US Dollar", symbol: "$"),
        CurrencyOption(code: "EUR", name: "Euro", symbol: "EUR"),
        CurrencyOption(code: "RUB", name: "Russian Ruble", symbol: "RUB"),
        CurrencyOption(code: "GBP", name: "British Pound", symbol: "GBP")
    ]

    static func symbol(for code: String) -> String {
        options.first(where: { $0.code == code })?.symbol ?? code
    }

    static func format(_ amount: Double, code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.currencySymbol = symbol(for: code)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(symbol(for: code))\(String(format: "%.2f", amount))"
    }

    static func code(fromSymbol symbol: String) -> String? {
        options.first(where: { $0.symbol == symbol })?.code
    }
}
