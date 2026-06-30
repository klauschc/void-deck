import SwiftUI
import Observation

@Observable
final class ReadingViewModel {
    var reading: Reading?
    var followUpMessage: String = ""
    var messages: [ChatMessage] = []
    var isLoading = false
    
    func createReading(question: String, spreadId: String, cards: [SelectedCard]) async {
        isLoading = true
        defer { isLoading = false }
        do {
            reading = try await APIClient.shared.createReading(question: question, spreadId: spreadId, cards: cards)
            messages = reading?.messages ?? []
        } catch { print("Failed to create reading: \(error)") }
    }
    
    func sendFollowUp() async {
        guard let reading, !followUpMessage.isEmpty else { return }
        let msg = followUpMessage
        followUpMessage = ""
        let userMsg = ChatMessage(id: nil, readingId: nil, role: .user, content: msg, createdAt: nil)
        messages.append(userMsg)
        do {
            let reply = try await APIClient.shared.sendFollowUp(readingId: reading.id, message: msg)
            if let response = reply.response {
                let aiMsg = ChatMessage(id: nil, readingId: nil, role: .assistant, content: response, createdAt: nil)
                messages.append(aiMsg)
            }
        } catch { print("Follow-up failed: \(error)") }
    }
}
