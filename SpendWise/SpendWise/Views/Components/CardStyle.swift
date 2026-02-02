import SwiftUI

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let background: AnyShapeStyle

    init(background: AnyShapeStyle = AnyShapeStyle(Theme.cardBackground)) {
        self.background = background
    }

    func body(content: Content) -> some View {
        content
            .padding(Theme.spacing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(colorScheme == .dark ? Theme.separator.opacity(0.28) : Theme.separator.opacity(0.08), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.18 : 0.08),
                radius: 12,
                x: 0,
                y: 6
            )
    }
}

extension View {
    func cardStyle(background: some ShapeStyle = Theme.cardBackground) -> some View {
        modifier(CardStyle(background: AnyShapeStyle(background)))
    }
}
