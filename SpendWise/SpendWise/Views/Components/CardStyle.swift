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
                    .strokeBorder(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [Theme.separator.opacity(0.3), Theme.accent.opacity(0.16)]
                                : [Color.white.opacity(0.7), Theme.accent.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(alignment: .top) {
                shape
                    .inset(by: 1.2)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(colorScheme == .dark ? 0.08 : 0.28), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .allowsHitTesting(false)
            }
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.18 : 0.08),
                radius: 14,
                x: 0,
                y: 7
            )
            .shadow(
                color: Theme.accent.opacity(colorScheme == .dark ? 0.14 : 0.1),
                radius: 12,
                x: 0,
                y: 4
            )
    }
}

extension View {
    func cardStyle(background: some ShapeStyle = Theme.cardBackground) -> some View {
        modifier(CardStyle(background: AnyShapeStyle(background)))
    }
}
