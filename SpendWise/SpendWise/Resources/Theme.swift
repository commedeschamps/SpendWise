import SwiftUI

enum Theme {
    static let background = Color(red: 0.96, green: 0.96, blue: 0.95)
    static let cardBackground = Color.white
    static let accent = Color(red: 0.06, green: 0.49, blue: 0.45)
    static let income = Color(red: 0.16, green: 0.67, blue: 0.38)
    static let expense = Color(red: 0.87, green: 0.33, blue: 0.31)
    static let textPrimary = Color(red: 0.12, green: 0.12, blue: 0.12)
    static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.45)

    static let cornerRadius: CGFloat = 16
    static let cardShadow = Color.black.opacity(0.08)
    static let spacing: CGFloat = 16
    static let compactSpacing: CGFloat = 8

    static let titleFont = Font.custom("Avenir Next Demi Bold", size: 22)
    static let subtitleFont = Font.custom("Avenir Next Medium", size: 16)
    static let bodyFont = Font.custom("Avenir Next Regular", size: 14)
}
