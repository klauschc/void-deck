import SwiftUI
import Observation

@Observable
final class CardSelectionViewModel {
    var allCards: [TarotCard] = []
    var selectedCards: [(card: TarotCard, orientation: String)] = []
    var requiredCount: Int = 3
    
    var groupedCards: [(String, [TarotCard])] {
        let major = allCards.filter { $0.arcana.lowercased() == "major" }
        let cups = allCards.filter { $0.suit?.lowercased() == "cups" }
        let wands = allCards.filter { $0.suit?.lowercased() == "wands" }
        let swords = allCards.filter { $0.suit?.lowercased() == "swords" }
        let pentacles = allCards.filter { $0.suit?.lowercased() == "pentacles" }
        return [("大阿爾克那", major), ("聖杯", cups), ("權杖", wands), ("寶劍", swords), ("錢幣", pentacles)].filter { !$0.1.isEmpty }
    }
    
    var isComplete: Bool { selectedCards.count == requiredCount }
    
    func isSelected(_ card: TarotCard) -> Bool { selectedCards.contains(where: { $0.card.id == card.id }) }
    
    func selectCard(_ card: TarotCard) { guard selectedCards.count < requiredCount, !isSelected(card) else { return }; selectedCards.append((card, "upright")) }
    
    func setOrientation(at index: Int, to orientation: String) { guard index < selectedCards.count else { return }; selectedCards[index].orientation = orientation }
    
    func getSelectedCards() -> [SelectedCard] {
        selectedCards.enumerated().map { i, entry in SelectedCard(positionIndex: i + 1, cardId: entry.card.id, orientation: entry.orientation) }
    }
    
    func loadCards() async { do { allCards = try await APIClient.shared.fetchCards() } catch { print("Failed to load cards: \(error)") } }
}
