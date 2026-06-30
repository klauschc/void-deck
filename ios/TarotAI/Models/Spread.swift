import Foundation

struct Spread: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameZh: String
    let description: String?
    let cardCount: Int
    let positions: [Position]
    
    struct Position: Codable, Identifiable, Hashable {
        let position: Int?
        let positionIndex: Int?
        let name: String?
        let nameZh: String?
        let description: String?
        var id: Int { position ?? positionIndex ?? 0 }
        var displayName: String { nameZh ?? name ?? "" }
    }
}
