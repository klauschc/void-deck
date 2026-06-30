import SwiftUI

struct CardSelectionView: View {
    @Environment(HomeViewModel.self) private var homeVM
    @State private var vm = CardSelectionViewModel()
    @State private var showPicker = false
    @State private var pickerIndex = 0
    @State private var readingVM = ReadingViewModel()
    
    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            VStack(spacing: 0) {
                Text("選擇 \(vm.requiredCount) 張牌").font(.title2).foregroundStyle(.white).padding(.top)
                ScrollView {
                    ForEach(vm.groupedCards, id: \.0) { group, cards in
                        Section {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                ForEach(cards) { card in
                                    Button {
                                        if !vm.isSelected(card) { vm.selectCard(card); pickerIndex = vm.selectedCards.count - 1; showPicker = true }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(suitIcon(for: card)).font(.title2)
                                            Text(card.nameZh).font(.caption2).foregroundStyle(.white).lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity).padding(6)
                                        .background { RoundedRectangle(cornerRadius: 10).fill(.clear).glassEffect(.regular) }
                                        .overlay { if vm.isSelected(card) { RoundedRectangle(cornerRadius: 10).stroke(TarotTheme.primaryStart, lineWidth: 2) } }
                                    }
                                }
                            }
                        } header: { Text(group).font(.headline).foregroundStyle(TarotTheme.accent).frame(maxWidth: .infinity, alignment: .leading).padding(.top).padding(.leading, 4) }
                    }
                }.padding(.horizontal)
                if !vm.selectedCards.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(Array(vm.selectedCards.enumerated()), id: \.offset) { i, entry in
                            HStack {
                                Text("\(i + 1). \(entry.card.nameZh)").foregroundStyle(.white)
                                Spacer()
                                Text(entry.orientation == "upright" ? "正位" : "逆位").font(.caption).foregroundStyle(TarotTheme.accent)
                                Button { pickerIndex = i; showPicker = true } label: { Image(systemName: "arrow.triangle.2.circlepath").font(.caption) }
                            }.padding(10).background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        if vm.isComplete {
                            Button { Task { readingVM = ReadingViewModel(); await readingVM.createReading(question: homeVM.question, spreadId: homeVM.selectedSpread?.id ?? "past_present_future", cards: vm.getSelectedCards()); homeVM.currentReading = readingVM.reading } } label: { Text("開始占卜").fontWeight(.semibold) }.buttonStyle(.borderedProminent).tint(TarotTheme.primaryStart)
                        }
                    }.padding().background(.ultraThinMaterial)
                }
            }
        }
        .sheet(isPresented: $showPicker) { CardOrientationPicker(orientation: Binding(get: { vm.selectedCards[pickerIndex].orientation }, set: { vm.setOrientation(at: pickerIndex, to: $0) })) }
        .task { vm.requiredCount = homeVM.selectedSpread?.cardCount ?? 3; await vm.loadCards() }
        .navigationTitle("選牌")
        .navigationDestination(item: Binding(get: { homeVM.currentReading }, set: { homeVM.currentReading = $0 })) { reading in ReadingResultView(reading: reading).environment(readingVM) }
    }
    
    func suitIcon(for card: TarotCard) -> String {
        if card.arcana.lowercased() == "major" { return "[\"the_fool\",\"the_magician\",\"the_high_priestess\",\"the_empress\",\"the_emperor\",\"the_hierophant\",\"the_lovers\",\"the_chariot\",\"strength\",\"the_hermit\",\"wheel_of_fortune\",\"justice\",\"the_hanged_man\",\"death\",\"temperance\",\"the_devil\",\"the_tower\",\"the_star\",\"the_moon\",\"the_sun\",\"judgement\",\"the_world\"].firstIndex(of: card.id).map { String($0) } ?? "☆" }
        switch card.suit?.lowercased() {
        case "cups": return "?"
        case "wands": return "?"
        case "swords": return "?"
        case "pentacles": return "?"
        default: return "🃏"
        }
    }
}
