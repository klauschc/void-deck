import SwiftUI

struct ContentView: View {
    @Environment(HomeViewModel.self) private var homeViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: Binding(get: { homeViewModel.navigationPath }, set: { homeViewModel.navigationPath = $0 })) {
                HomeView(selectedTab: $selectedTab)
                    .navigationDestination(for: String.self) { route in
                        switch route {
                        case "spreads": SpreadSelectionView()
                        case "question": QuestionInputView()
                        case "cards": CardSelectionView()
                        case "readingResult": ReadingResultView(reading: homeViewModel.currentReading ?? Reading(id: "", question: "", spreadId: "", selectedCards: [], createdAt: nil, updatedAt: nil))
                        default: EmptyView()
                        }
                    }
            }
            .tabItem { Label("占卜", systemImage: "sparkles") }.tag(0)

            NavigationStack {
                HistoryView()
                    .navigationDestination(for: Reading.self) { reading in ReadingResultView(reading: reading) }
            }
            .tabItem { Label("紀錄", systemImage: "clock") }.tag(1)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("設定", systemImage: "gear") }.tag(2)
        }
        .tint(TarotTheme.primaryStart)
    }
}
