import SwiftUI

@main
struct TarotAIApp: App {
    @State private var homeViewModel = HomeViewModel()
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26, *) {
                ContentView().environment(homeViewModel)
            }
        }
    }
}
