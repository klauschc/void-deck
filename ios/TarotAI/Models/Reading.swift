import Foundation

struct Reading: Codable, Identifiable, Hashable {
    let id: String
    let question: String
    let spreadId: String
    let selectedCards: [SelectedCard]
    var aiInterpretation: String?
    var messages: [ChatMessage]?
    let createdAt: String?
    let updatedAt: String?

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Reading, rhs: Reading) -> Bool { lhs.id == rhs.id }

    struct SelectedCard: Codable, Hashable {
        let positionIndex: Int?
        let cardId: String?
        let orientation: String?
        let position: Int?
        let card_id: String?
        let name: String?
        let nameZh: String?
        let description: String?

        func hash(into hasher: inout Hasher) {
            hasher.combine(positionIndex)
            hasher.combine(cardId)
        }
        static func == (lhs: SelectedCard, rhs: SelectedCard) -> Bool {
            lhs.positionIndex == rhs.positionIndex && lhs.cardId == rhs.cardId
        }
    }
}
