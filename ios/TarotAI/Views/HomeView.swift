import SwiftUI

struct HomeView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            VStack(spacing: 32) {
                Spacer()
                Image(systemName: "sparkles").font(.system(size: 60)).foregroundStyle(TarotTheme.accent)
                Text("Void Deck").font(.largeTitle).fontWeight(.bold).foregroundStyle(.white)
                Text("讓塔羅為你指引方向").font(.body).foregroundStyle(TarotTheme.accent)
                Spacer()
                NavigationLink("開始占卜", value: "spreads").buttonStyle(.borderedProminent).tint(TarotTheme.primaryStart).controlSize(.large)
                Button("占卜紀錄") { selectedTab = 1 }.buttonStyle(.bordered).tint(.white.opacity(0.3))
                Spacer()
            }.padding()
        }
        .task { await viewModel.loadSpreads() }
    }
}
