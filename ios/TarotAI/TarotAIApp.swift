import SwiftUI

@main
struct TarotAIApp: App {
    @State private var homeViewModel = HomeViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(homeViewModel)
        }
    }
}
