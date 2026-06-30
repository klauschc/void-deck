import SwiftUI

struct ReadingResultView: View {
    let reading: Reading
    @State private var chatVM = ReadingViewModel()
    
    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            ScrollView {
                VStack(spacing: 16) {
                    Text(reading.question).font(.headline).foregroundStyle(.white).padding(.top)
                    ForEach(Array(reading.selectedCards.enumerated()), id: \.offset) { i, card in
                        GlassCard(content: VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(i+1). \(card.cardId)").font(.subheadline).foregroundStyle(TarotTheme.accent)
                                Spacer()
                                Text(card.orientation == "upright" ? "正位" : "逆位").font(.caption).padding(4).background(TarotTheme.primaryStart.opacity(0.3)).clipShape(Capsule())
                            }
                        })
                    }
                    if let ai = reading.aiInterpretation {
                        GlassCard(content: VStack(alignment: .leading, spacing: 8) {
                            HStack { Image(systemName: "sparkles").foregroundStyle(TarotTheme.accent); Text("AI 解讀").font(.headline).foregroundStyle(.white) }
                            Text(ai).font(.body).foregroundStyle(.white.opacity(0.9)).lineSpacing(4)
                        })
                    }
                    NavigationLink(destination: ReadingChatView(reading: reading)) {
                        HStack { Image(systemName: "bubble.left.and.bubble.right"); Text("繼續對話") }
                    }.buttonStyle(.borderedProminent).tint(TarotTheme.primaryStart)
                }.padding()
            }
        }
        .navigationTitle("解讀結果")
        .task { chatVM.reading = reading; chatVM.messages = reading.messages ?? [] }
    }
}
