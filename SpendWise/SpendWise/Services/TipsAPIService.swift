import Foundation
import Alamofire

struct TipsAPIService {
    private let endpointBase = "https://open.er-api.com/v6/latest"

    func fetchTip() async throws -> Tip {
        let payload = try await fetchRates(baseCode: "USD")

        guard let kzt = payload.rates["KZT"],
              let eur = payload.rates["EUR"],
              let rub = payload.rates["RUB"] else {
            throw URLError(.cannotParseResponse)
        }

        let text = [
            formatRate(usd: 1, to: kzt, currency: "KZT"),
            formatRate(usd: 1, to: eur, currency: "EUR"),
            formatRate(usd: 1, to: rub, currency: "RUB")
        ].joined(separator: "\n")

        return Tip(id: UUID().uuidString, text: text, author: "ExchangeRate-API")
    }

    func convert(amount: Double, from sourceCode: String, to targetCode: String) async throws -> CurrencyConversion {
        let from = sourceCode.uppercased()
        let to = targetCode.uppercased()
        guard amount >= 0 else {
            throw URLError(.badServerResponse)
        }

        if from == to {
            return CurrencyConversion(
                inputAmount: amount,
                sourceCode: from,
                targetCode: to,
                rate: 1,
                outputAmount: amount
            )
        }

        let payload = try await fetchRates(baseCode: from)
        guard let rate = payload.rates[to] else {
            throw URLError(.cannotParseResponse)
        }

        return CurrencyConversion(
            inputAmount: amount,
            sourceCode: from,
            targetCode: to,
            rate: rate,
            outputAmount: amount * rate
        )
    }

    private func fetchRates(baseCode: String) async throws -> ExchangeRatesResponse {
        guard let endpoint = URL(string: "\(endpointBase)/\(baseCode.uppercased())") else {
            throw URLError(.badURL)
        }

        let data = try await AF.request(endpoint)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value
        return try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)
    }

    private func formatRate(usd: Double, to rate: Double, currency: String) -> String {
        String(format: "%.0f USD = %.2f %@", usd, rate, currency)
    }
}

struct CurrencyConversion {
    let inputAmount: Double
    let sourceCode: String
    let targetCode: String
    let rate: Double
    let outputAmount: Double
}

private struct ExchangeRatesResponse: Codable {
    let baseCode: String
    let rates: [String: Double]

    private enum CodingKeys: String, CodingKey {
        case baseCode = "base_code"
        case rates
    }
}
