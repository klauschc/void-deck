import SwiftUI

struct ReadingChatView: View {
    @State private var viewModel = ReadingViewModel()
    let reading: Reading
    @State private var inputText = ""
    
    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { msg in
                            HStack {
                                if msg.role == .assistant { Spacer(minLength: 60) }
                                Text(msg.content).padding(12).foregroundStyle(.white)
                                    .background { RoundedRectangle(cornerRadius: 16).fill(msg.role == .user ? TarotTheme.userBubbleStart : TarotTheme.assistantBubble.opacity(0.5)) }
                                if msg.role == .user { Spacer(minLength: 60) }
                            }
                        }
                    }.padding()
                }
                HStack {
                    TextField("你可以繼續追問...", text: $inputText).padding(10).background(.ultraThinMaterial).foregroundStyle(.white)
                    Button { Task { viewModel.followUpMessage = inputText; await viewModel.sendFollowUp(); inputText = "" } } label: { Image(systemName: "arrow.up.circle.fill").font(.title2).foregroundStyle(TarotTheme.primaryStart) }
                }.padding()
            }
        }
        .navigationTitle("追問")
        .task { viewModel.reading = reading; viewModel.messages = reading.messages ?? [] }
    }
}
