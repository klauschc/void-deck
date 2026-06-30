import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: Int?
    let readingId: String?
    let role: MessageRole
    let content: String
    let createdAt: String?
}

enum MessageRole: String, Codable {
    case user, assistant
}
