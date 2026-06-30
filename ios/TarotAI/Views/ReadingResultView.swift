import SwiftUI

struct ReadingResultView: View {
    let reading: Reading
    @State private var viewModel = ReadingViewModel()
    
    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            ScrollView {
                VStack(spacing: 16) {
                    Text(reading.question).font(.headline).foregroundStyle(.white)
                    if let ai = reading.aiInterpretation {
                        GlassCard(content: Text(ai).foregroundStyle(.white.opacity(0.9)))
                    }
                    NavigationLink("完整對話", value: reading).buttonStyle(.borderedProminent).tint(TarotTheme.primaryStart)
                }.padding()
            }
        }
        .navigationTitle("解讀結果")
        .task { viewModel.reading = reading; viewModel.messages = reading.messages ?? [] }
    }
}
