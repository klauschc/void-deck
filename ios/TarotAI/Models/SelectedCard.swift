import Foundation

struct SelectedCard: Codable, Hashable {
    let cardId: String
    let positionIndex: Int
    let orientation: String

    func hash(into hasher: inout Hasher) { hasher.combine(cardId); hasher.combine(positionIndex) }
    static func == (lhs: SelectedCard, rhs: SelectedCard) -> Bool { lhs.cardId == rhs.cardId && lhs.positionIndex == rhs.positionIndex }
}
