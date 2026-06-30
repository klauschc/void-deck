import SwiftUI
import Observation

@Observable
final class HistoryViewModel {
    var readings: [Reading] = []
    
    func loadReadings() async {
        do { readings = try await APIClient.shared.fetchReadings() } catch { print("Failed to load readings: \(error)") }
    }
}
