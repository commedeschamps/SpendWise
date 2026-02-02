import Foundation

struct TipsAPIService {
    private let endpoint = URL(string: "https://api.quotable.io/random")!

    func fetchTip() async throws -> Tip {
        let (data, _) = try await URLSession.shared.data(from: endpoint)
        let response = try JSONDecoder().decode(TipResponse.self, from: data)
        return Tip(id: response.id, text: response.content, author: response.author)
    }
}

private struct TipResponse: Codable {
    let id: String
    let content: String
    let author: String

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content
        case author
    }
}
