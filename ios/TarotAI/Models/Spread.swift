import Foundation

struct Spread: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameZh: String
    let description: String?
    let cardCount: Int
    let positions: [Position]

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Spread, rhs: Spread) -> Bool { lhs.id == rhs.id }

    struct Position: Codable, Identifiable, Hashable {
        let positionIndex: Int?
        let position: Int?
        let name: String?
        let nameZh: String?
        let description: String?
        var id: Int { positionIndex ?? position ?? 0 }
        var displayName: String { nameZh ?? name ?? "" }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }
}
