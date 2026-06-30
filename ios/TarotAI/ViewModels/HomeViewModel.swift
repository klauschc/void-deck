import SwiftUI
import Observation

@Observable
final class HomeViewModel {
    var spreads: [Spread] = []
    var selectedSpread: Spread?
    var question: String = ""
    var currentReading: Reading?
    var navigationPath = NavigationPath()
    var isLoading: Bool = false
    var errorMessage: String?

    func loadSpreads() async {
        do { spreads = try await APIClient.shared.fetchSpreads() } catch { print("Failed to load spreads: \(error)") }
    }

    func createReading(question: String, spreadId: String, cards: [SelectedCard]) async -> Reading? {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            let reading = try await APIClient.shared.createReading(question: question, spreadId: spreadId, cards: cards)
            currentReading = reading
            return reading
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
