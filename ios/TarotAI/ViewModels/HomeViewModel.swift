import SwiftUI
import Observation

@Observable
final class HomeViewModel {
    var spreads: [Spread] = []
    var selectedSpread: Spread?
    var question: String = ""
    var navigationPath = NavigationPath()
    
    func loadSpreads() async {
        do { spreads = try await APIClient.shared.fetchSpreads() } catch { print("Failed to load spreads: \(error)") }
    }
}
