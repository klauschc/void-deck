import SwiftUI
import Observation

@Observable
final class SettingsViewModel {
    var baseURL: String { didSet { UserDefaults.standard.set(baseURL, forKey: "api_base_url") } }
    var apiKey: String { didSet { UserDefaults.standard.set(apiKey, forKey: "api_key") } }
    var model: String { didSet { UserDefaults.standard.set(model, forKey: "api_model") } }

    init() {
        self.baseURL = UserDefaults.standard.string(forKey: "api_base_url") ?? "http://localhost:8000"
        self.apiKey = UserDefaults.standard.string(forKey: "api_key") ?? ""
        self.model = UserDefaults.standard.string(forKey: "api_model") ?? "minimaxai/minimax-m3"
    }

    func save() {
        UserDefaults.standard.set(baseURL, forKey: "api_base_url")
        UserDefaults.standard.set(apiKey, forKey: "api_key")
        UserDefaults.standard.set(model, forKey: "api_model")
    }
}
