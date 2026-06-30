import SwiftUI

struct CardSelectionView: View {
    @Environment(HomeViewModel.self) private var homeViewModel
    @State private var viewModel = CardSelectionViewModel()
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    if let spread = homeViewModel.selectedSpread {
                        Text(spread.nameZh).font(.title.weight(.bold)).foregroundColor(.white)
                        Text("選擇 \(spread.cardCount) 張牌").font(.subheadline).foregroundColor(TarotTheme.accent.opacity(0.7))
                    }
                }.padding(.top, 16).padding(.bottom, 12)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(TarotTheme.accent)
                    Text("載入塔羅牌中...").font(.subheadline).foregroundColor(TarotTheme.accent.opacity(0.6)).padding(.top, 8)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    GlassCard { Text(error).foregroundColor(.red.opacity(0.8)) }.padding(.horizontal, 20)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(viewModel.groupedCards(), id: \.title) { group in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(group.title).font(.headline).foregroundColor(TarotTheme.accent).padding(.horizontal, 20)
                                    LazyVGrid(columns: columns, spacing: 10) {
                                        ForEach(group.cards) { card in
                                            let isSelected = viewModel.isCardSelected(card)
                                            Button { viewModel.selectCard(card) } label: {
                                                VStack(spacing: 4) {
                                                    if card.arcana.lowercased() == "major" {
                                                        Text("\(card.number)").font(.caption2).foregroundColor(TarotTheme.accent.opacity(0.7))
                                                    } else {
                                                        Image(systemName: suitIcon(for: card.suit)).font(.caption2).foregroundColor(TarotTheme.accent.opacity(0.7))
                                                    }
                                                    Text(card.nameZh).font(.caption.weight(.medium)).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(2)
                                                }
                                                .frame(height: 100).frame(maxWidth: .infinity).padding(8)
                                                .background { RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.clear).glassEffect(.regular.interactive()) }
                                                .overlay { if isSelected { RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(TarotTheme.primaryStart, lineWidth: 2).shadow(color: TarotTheme.primaryStart.opacity(0.5), radius: 6) } }
                                            }
                                            .buttonStyle(.plain).disabled(isSelected).opacity(isSelected ? 0.4 : 1.0)
                                        }
                                    }.padding(.horizontal, 20)
                                }
                            }
                        }.padding(.bottom, 160).padding(.top, 8)
                    }
                }
            }.ignoresSafeArea(.keyboard)

            VStack {
                Spacer()
                VStack(spacing: 12) {
                    if !viewModel.selectedCards.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(viewModel.selectedCards.enumerated()), id: \.element.card.id) { index, item in
                                    VStack(spacing: 2) {
                                        Text(item.card.nameZh).font(.caption2.weight(.medium)).foregroundColor(.white).lineLimit(1)
                                        Text(item.orientation == "upright" ? "正" : "逆").font(.caption2).foregroundColor(TarotTheme.accent)
                                    }
                                    .padding(.horizontal, 12).padding(.vertical, 8)
                                    .background { Capsule().fill(TarotTheme.primaryStart.opacity(0.3)) }
                                }
                            }.padding(.horizontal, 20)
                        }
                        Text("第 \(viewModel.selectedCards.count) / \(viewModel.maxCards) 張").font(.caption).foregroundColor(TarotTheme.accent.opacity(0.7))
                    }
                    if viewModel.isComplete {
                        Button {
                            Task {
                                guard let spread = homeViewModel.selectedSpread else { return }
                                if let reading = await homeViewModel.createReading(question: homeViewModel.question, spreadId: spread.id, cards: viewModel.getSelectedCards()) {
                                    homeViewModel.currentReading = reading
                                    homeViewModel.navigationPath.append("readingResult")
                                }
                            }
                        } label: {
                            HStack {
                                if homeViewModel.isLoading { ProgressView().tint(.white) }
                                Text("繼續").font(.headline).foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(TarotTheme.primaryGradient).clipShape(Capsule())
                        }
                        .disabled(homeViewModel.isLoading).padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 16)
                .background { RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.clear).glassEffect(.regular.interactive()) }
                .padding(.horizontal, 12).padding(.bottom, 8)
            }
        }
        .sheet(isPresented: Binding(get: { viewModel.cardToOrient != nil }, set: { if !$0 { viewModel.cancelOrientation() } })) {
            if let card = viewModel.cardToOrient {
                CardOrientationPicker(card: card, onConfirm: { orientation in viewModel.setOrientation(orientation) }, onCancel: { viewModel.cancelOrientation() })
                    .presentationDetents([.height(240)])
            }
        }
        .task { viewModel.maxCards = homeViewModel.selectedSpread?.cardCount ?? 0; await viewModel.loadCards() }
    }

    func suitIcon(for suit: String?) -> String {
        switch suit?.lowercased() {
        case "cups": return "drop.fill"
        case "wands": return "flame.fill"
        case "swords": return "bolt.fill"
        case "pentacles": return "circle.hexagongrid.fill"
        default: return "sparkles"
        }
    }
}
