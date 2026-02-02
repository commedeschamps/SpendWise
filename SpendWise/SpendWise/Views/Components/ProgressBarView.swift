import SwiftUI

struct ProgressBarView: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.background)
                Capsule()
                    .fill(progressColor)
                    .frame(width: width * CGFloat(max(0, min(progress, 1))))
            }
        }
        .animation(.easeInOut(duration: 0.6), value: progress)
    }

    private var progressColor: Color {
        progress >= 1 ? Theme.expense : Theme.accent
    }
}

#Preview {
    ProgressBarView(progress: 0.65)
        .frame(height: 10)
        .padding()
}
