import SwiftUI

struct RootTabView: View {
    @StateObject private var transactionsViewModel = TransactionViewModel()
    @StateObject private var tipsViewModel = TipsViewModel()
    @StateObject private var goalsViewModel = GoalsViewModel()

    var body: some View {
        TabView {
            HomeView(viewModel: transactionsViewModel, tipsViewModel: tipsViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            NavigationStack {
                TransactionListView(viewModel: transactionsViewModel)
            }
            .tabItem {
                Label("Transactions", systemImage: "list.bullet.rectangle")
            }

            NavigationStack {
                AnalyticsView(viewModel: transactionsViewModel)
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.bar.xaxis")
            }

            NavigationStack {
                GoalsView(viewModel: goalsViewModel)
            }
            .tabItem {
                Label("Goals", systemImage: "target")
            }

            NavigationStack {
                ExchangeView()
            }
            .tabItem {
                Label("Exchange", systemImage: "arrow.left.arrow.right.circle")
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Theme.accent)
        .toolbarBackground(Theme.elevatedBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear {
            transactionsViewModel.startListening()
            tipsViewModel.fetchTip()
        }
    }
}

#Preview {
    RootTabView()
}
