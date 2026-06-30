import Foundation

struct Reading: Codable, Identifiable {
    let id: String
    let question: String
    let spreadId: String
    let selectedCards: [SelectedCard]
    var aiInterpretation: String?
    var messages: [ChatMessage]?
    let createdAt: String?
    let updatedAt: String?
}
