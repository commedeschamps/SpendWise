import SwiftUI

struct TipsCardView: View {
    @ObservedObject var viewModel: TipsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            HStack {
                Text("Exchange Rates")
                    .font(Theme.subtitleFont)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Button("Update") {
                    viewModel.fetchTip()
                }
                .font(Theme.captionFont)
            }

            content
        }
        .cardStyle()
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Text("Tap update to fetch the latest rates.")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        case .loading:
            ProgressView()
        case .success:
            if let tip = viewModel.tip {
                VStack(alignment: .leading, spacing: Theme.compactSpacing) {
                    Text(tip.text)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                        .lineSpacing(4)
                    Text(tip.author)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                }
            } else {
                Text("No rates available.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            }
        case .error(let message):
            VStack(alignment: .leading, spacing: Theme.compactSpacing) {
                Text("Couldn't load rates")
                    .font(Theme.subtitleFont)
                Text(message)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}

#Preview {
    TipsCardView(viewModel: TipsViewModel())
        .padding()
        .background(Theme.background)
}
