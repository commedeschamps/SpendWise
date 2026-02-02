import SwiftUI

struct TipsCardView: View {
    @ObservedObject var viewModel: TipsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            HStack {
                Text("Daily Tip")
                    .font(Theme.subtitleFont)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Button("Refresh") {
                    viewModel.fetchTip()
                }
                .font(Theme.bodyFont)
            }

            content
        }
        .padding(Theme.spacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, x: 0, y: 8)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Text("Tap refresh for a new tip.")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        case .loading:
            ProgressView()
        case .success:
            if let tip = viewModel.tip {
                VStack(alignment: .leading, spacing: Theme.compactSpacing) {
                    Text("\"\(tip.text)\"")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text("- \(tip.author)")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textSecondary)
                }
            } else {
                Text("No tip available.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            }
        case .error(let message):
            VStack(alignment: .leading, spacing: Theme.compactSpacing) {
                Text("Couldn't load tip")
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
