import SwiftUI
import Observation

@Observable
class CardSelectionViewModel {
    var allCards: [TarotCard] = []
    var selectedCards: [(card: TarotCard, orientation: String)] = []
    var currentSelectionStep: Int = 0
    var isLoading: Bool = false
    var errorMessage: String?
    var cardToOrient: TarotCard? = nil
    var maxCards: Int = 0

    var isComplete: Bool { selectedCards.count == maxCards && maxCards > 0 }

    func loadCards() async {
        isLoading = true; errorMessage = nil
        do { allCards = try await APIClient.shared.fetchCards() } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    func selectCard(_ card: TarotCard) {
        guard selectedCards.count < maxCards, !isCardSelected(card) else { return }
        cardToOrient = card
    }

    func setOrientation(_ orientation: String) {
        guard let card = cardToOrient else { return }
        selectedCards.append((card: card, orientation: orientation))
        currentSelectionStep = selectedCards.count
        cardToOrient = nil
    }

    func cancelOrientation() { cardToOrient = nil }

    func isCardSelected(_ card: TarotCard) -> Bool { selectedCards.contains(where: { $0.card.id == card.id }) }

    func getSelectedCards() -> [SelectedCard] {
        selectedCards.enumerated().map { i, item in SelectedCard(cardId: item.card.id, positionIndex: i, orientation: item.orientation) }
    }

    func groupedCards() -> [(title: String, cards: [TarotCard])] {
        var groups: [(String, [TarotCard])] = []
        let major = allCards.filter { $0.arcana.lowercased() == "major" }.sorted { $0.number < $1.number }
        if !major.isEmpty { groups.append(("大阿爾克那", major)) }
        for (suit, name) in [("cups","聖杯"),("wands","權杖"),("swords","寶劍"),("pentacles","錢幣")] {
            let cards = allCards.filter { ($0.suit ?? "").lowercased() == suit }.sorted { $0.number < $1.number }
            if !cards.isEmpty { groups.append((name, cards)) }
        }
        return groups
    }
}
