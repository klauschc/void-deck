import SwiftUI

struct ReadingChatView: View {
    let reading: Reading
    @State private var vm = ReadingViewModel()
    @State private var inputText = ""
    let suggestions = ["我應該點做？","對方點諗？","未來一個月會點？","可唔可以講深一層？"]

    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(vm.messages.enumerated()), id: \.offset) { i, msg in
                                chatBubble(msg)
                                    .id(i)
                                    .padding(.horizontal)
                            }
                        }.padding(.vertical)
                    }
                    .onChange(of: vm.messages.count) {
                        if let last = vm.messages.indices.last {
                            withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                        }
                    }
                }
                VStack(spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions, id: \.self) { chip in
                                Button(chip) { inputText = chip }
                                    .buttonStyle(.bordered).tint(TarotTheme.accent.opacity(0.5)).controlSize(.small)
                            }
                        }.padding(.horizontal)
                    }
                    HStack {
                        TextField("你可以繼續追問...", text: $inputText)
                            .padding(10).background(.ultraThinMaterial).foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        Button {
                            guard !inputText.isEmpty else { return }
                            let msg = inputText; inputText = ""
                            Task { await vm.sendMessage(content: msg) }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill").font(.title2).foregroundStyle(TarotTheme.primaryStart)
                        }
                    }.padding(.horizontal)
                }.padding(.vertical, 8).background(.ultraThinMaterial)
            }
        }
        .navigationTitle("追問")
        .task { vm.reading = reading; vm.messages = reading.messages ?? [] }
    }

    func chatBubble(_ msg: ChatMessage) -> some View {
        HStack(alignment: .top) {
            if msg.role == .assistant { Spacer(minLength: 50) }
            Text(msg.content).padding(12).foregroundStyle(.white)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(msg.role == .user ? TarotTheme.primaryStart : TarotTheme.assistantBubble)
                }
            if msg.role == .user { Spacer(minLength: 50) }
        }
    }
}
