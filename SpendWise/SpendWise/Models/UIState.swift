import Foundation

enum UIState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}
