import Foundation
import Combine
import SwiftUI

@MainActor
final class TipsViewModel: ObservableObject {
    @Published var tip: Tip?
    @Published var state: UIState = .idle

    private let service: TipsAPIService

    init(service: TipsAPIService = TipsAPIService()) {
        self.service = service
    }

    func fetchTip() {
        state = .loading
        Task { [weak self] in
            guard let self else { return }
            do {
                let tip = try await service.fetchTip()
                self.tip = tip
                self.state = .success
            } catch {
                self.state = .error(error.localizedDescription)
            }
        }
    }
}
