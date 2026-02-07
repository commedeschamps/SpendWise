import SwiftUI

struct TipsCardView: View {
    @ObservedObject var viewModel: TipsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Theme.accentSoft)
                        .frame(width: 30, height: 30)
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Exchange Rates")
                        .font(Theme.subtitleFont)
                        .foregroundStyle(Theme.textPrimary)
                    stateBadge
                }

                Spacer()

                Button {
                    viewModel.fetchTip()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(Theme.captionFont)
                }
                .buttonStyle(.bordered)
                .tint(Theme.accentAlt)
                .controlSize(.small)
            }

            content
        }
        .cardStyle(background: Theme.softCardGradient)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Text("Tap refresh to fetch the latest rates.")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        case .loading:
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading market data...")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            }
        case .success:
            if let tip = viewModel.tip {
                VStack(alignment: .leading, spacing: Theme.compactSpacing) {
                    ForEach(tip.text.components(separatedBy: "\n"), id: \.self) { line in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Theme.accent)
                                .frame(width: 5, height: 5)
                            Text(line)
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
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

    @ViewBuilder
    private var stateBadge: some View {
        switch viewModel.state {
        case .idle:
            badge(text: "Idle", color: Theme.textSecondary)
        case .loading:
            badge(text: "Updating", color: Theme.accentAlt)
        case .success:
            badge(text: "Live", color: Theme.income)
        case .error:
            badge(text: "Error", color: Theme.expense)
        }
    }

    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(Theme.captionFont)
            .foregroundStyle(color)
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

#Preview {
    TipsCardView(viewModel: TipsViewModel())
        .padding()
        .background(Theme.background)
}
