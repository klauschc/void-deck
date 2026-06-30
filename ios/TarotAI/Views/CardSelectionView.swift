import SwiftUI

struct CardSelectionView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @State private var cards: [TarotCard] = []
    @State private var selectedIndices: Set<Int> = []
    
    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            VStack {
                Text("選牌 — Phase 4").foregroundStyle(.white)
            }
        }
        .task { do { cards = try await APIClient.shared.fetchCards() } catch {} }
    }
}
