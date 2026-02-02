import SwiftUI

struct RootTabView: View {
    @StateObject private var transactionsViewModel = TransactionViewModel()
    @StateObject private var tipsViewModel = TipsViewModel()

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

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Theme.accent)
        .onAppear {
            transactionsViewModel.startListening()
            tipsViewModel.fetchTip()
        }
    }
}

#Preview {
    RootTabView()
}
