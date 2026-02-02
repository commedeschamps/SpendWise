import SwiftUI

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(Theme.spacing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(colorScheme == .dark ? Theme.separator.opacity(0.25) : Color.clear, lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.08),
                radius: 12,
                x: 0,
                y: 6
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
