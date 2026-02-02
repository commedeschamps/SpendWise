import SwiftUI

struct ProgressBarView: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.tertiaryBackground)
                Capsule()
                    .fill(barGradient)
                    .frame(width: width * CGFloat(max(0, min(progress, 1))))
            }
        }
        .animation(.easeInOut(duration: 0.45), value: progress)
    }

    private var barGradient: LinearGradient {
        if progress >= 1 {
            return LinearGradient(colors: [Theme.expense, Theme.expense.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        }
        return LinearGradient(colors: [Theme.accent, Theme.accent.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
    }
}

#Preview {
    ProgressBarView(progress: 0.65)
        .frame(height: 10)
        .padding()
}
