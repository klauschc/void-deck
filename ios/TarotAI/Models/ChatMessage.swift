import Foundation

struct ChatMessage: Codable, Identifiable, Hashable {
    let id: Int?
    let readingId: String?
    let role: MessageRole
    let content: String
    let createdAt: String?

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool { lhs.id == rhs.id }
}

enum MessageRole: String, Codable, Hashable {
    case user, assistant
}
