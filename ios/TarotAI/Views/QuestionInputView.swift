import SwiftUI

struct QuestionInputView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @State private var questionText = ""

    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            VStack(spacing: 20) {
                Text("你想問塔羅甚麼？").font(.title2).foregroundStyle(.white)
                Text("試下問具體啲，例如感情、事業、方向...").font(.caption).foregroundStyle(TarotTheme.accent)
                GlassCard(content: TextField("你想問塔羅甚麼？", text: $questionText, axis: .vertical).foregroundStyle(.white).lineLimit(3...6))
                NavigationLink("繼續", value: "cards")
                    .buttonStyle(.borderedProminent).tint(TarotTheme.primaryStart)
                    .disabled(questionText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .simultaneousGesture(TapGesture().onEnded { viewModel.question = questionText })
            }.padding()
        }
        .navigationTitle("提問")
    }
}
