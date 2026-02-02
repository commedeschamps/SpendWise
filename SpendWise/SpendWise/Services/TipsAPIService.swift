import Foundation

struct TipsAPIService {
    private let endpoint = URL(string: "https://open.er-api.com/v6/latest/USD")!

    func fetchTip() async throws -> Tip {
        let (data, response) = try await URLSession.shared.data(from: endpoint)
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }

        let payload = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)

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

    private func formatRate(usd: Double, to rate: Double, currency: String) -> String {
        String(format: "%.0f USD = %.2f %@", usd, rate, currency)
    }
}

private struct ExchangeRatesResponse: Codable {
    let baseCode: String
    let rates: [String: Double]

    private enum CodingKeys: String, CodingKey {
        case baseCode = "base_code"
        case rates
    }
}
