import SwiftUI

struct SpreadSelectionView: View {
    @Environment(HomeViewModel.self) private var viewModel
    
    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            VStack(spacing: 20) {
                Text("選擇牌陣").font(.title2).fontWeight(.semibold).foregroundStyle(.white)
                ForEach(viewModel.spreads) { spread in
                    NavigationLink(value: "question") {
                        GlassCard(content: VStack(alignment: .leading, spacing: 8) {
                            Text(spread.nameZh).font(.headline).foregroundStyle(.white)
                            Text("\(spread.cardCount) 張牌").font(.caption).foregroundStyle(TarotTheme.accent)
                            if let desc = spread.description { Text(desc).font(.caption).foregroundStyle(.white.opacity(0.6)) }
                        })
                    }
                    .simultaneousGesture(TapGesture().onEnded { viewModel.selectedSpread = spread })
                    .overlay { if viewModel.selectedSpread?.id == spread.id { RoundedRectangle(cornerRadius: 20).stroke(TarotTheme.primaryStart, lineWidth: 2) } }
                }
            }.padding()
        }
        .navigationTitle("牌陣")
    }
}
