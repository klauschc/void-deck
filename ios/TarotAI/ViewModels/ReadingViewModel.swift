import SwiftUI
import Observation

@Observable
final class ReadingViewModel {
    var reading: Reading?
    var messages: [ChatMessage] = []
    var allCards: [TarotCard] = []

    func loadCards() async { do { allCards = try await APIClient.shared.fetchCards() } catch {} }

    func cardName(for cardId: String?) -> String {
        guard let cardId else { return "" }
        return allCards.first(where: { $0.id == cardId })?.nameZh ?? cardId
    }

    func card(for cardId: String?) -> TarotCard? {
        guard let cardId else { return nil }
        return allCards.first(where: { $0.id == cardId })
    }

    func sendMessage(content: String) async {
        guard let reading, !content.isEmpty else { return }
        messages.append(ChatMessage(id: nil, readingId: nil, role: .user, content: content, createdAt: nil))
        do {
            let reply = try await APIClient.shared.sendFollowUp(readingId: reading.id, message: content)
            if let response = reply.response {
                messages.append(ChatMessage(id: nil, readingId: nil, role: .assistant, content: response, createdAt: nil))
            }
        } catch { print("Failed to send: \(error)") }
    }
}
