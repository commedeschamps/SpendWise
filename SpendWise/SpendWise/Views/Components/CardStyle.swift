import SwiftUI

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let background: AnyShapeStyle

    init(background: AnyShapeStyle = AnyShapeStyle(Theme.cardBackground)) {
        self.background = background
    }

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
        content
            .padding(Theme.spacing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [Theme.separator.opacity(0.35), Theme.accent.opacity(0.18)]
                                : [Theme.separator.opacity(0.12), Theme.accent.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.18 : 0.08),
                radius: 12,
                x: 0,
                y: 6
            )
            .shadow(
                color: Theme.accent.opacity(colorScheme == .dark ? 0.16 : 0.08),
                radius: 10,
                x: 0,
                y: 3
            )
    }
}

extension View {
    func cardStyle(background: some ShapeStyle = Theme.cardBackground) -> some View {
        modifier(CardStyle(background: AnyShapeStyle(background)))
    }
}
