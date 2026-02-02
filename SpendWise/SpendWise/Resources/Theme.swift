import SwiftUI
import UIKit

enum Theme {
    static let background = Color(UIColor.systemGroupedBackground)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let elevatedBackground = Color(UIColor.systemBackground)
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let separator = Color(UIColor.separator)

    static let accent = Color(red: 0.06, green: 0.49, blue: 0.45)
    static let income = Color(red: 0.16, green: 0.67, blue: 0.38)
    static let expense = Color(red: 0.87, green: 0.33, blue: 0.31)

    static let cornerRadius: CGFloat = 18
    static let spacing: CGFloat = 16
    static let compactSpacing: CGFloat = 8

    static let titleFont: Font = .system(.title2, design: .rounded).weight(.semibold)
    static let subtitleFont: Font = .system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont: Font = .system(.body, design: .rounded)
    static let captionFont: Font = .system(.caption, design: .rounded)
    static let amountFont: Font = .system(.title3, design: .rounded).weight(.bold)
    static let heroAmountFont: Font = .system(.title, design: .rounded).weight(.bold)
}
