import SwiftUI

enum TarotTheme {
    static let bgStart = Color(red: 13/255, green: 2/255, blue: 33/255)
    static let bgEnd = Color(red: 26/255, green: 10/255, blue: 62/255)
    static let primaryStart = Color(red: 123/255, green: 47/255, blue: 190/255)
    static let primaryEnd = Color(red: 74/255, green: 29/255, blue: 138/255)
    static let accent = Color(red: 232/255, green: 213/255, blue: 183/255)
    static let glassBg = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.12)
    static let userBubbleStart = Color(red: 107/255, green: 63/255, blue: 160/255)
    static let userBubbleEnd = Color(red: 61/255, green: 31/255, blue: 110/255)
    static let assistantBubble = Color.white.opacity(0.10)
    static var cosmicBg: some View { LinearGradient(colors: [bgStart, bgEnd], startPoint: .top, endPoint: .bottom).ignoresSafeArea() }
    static var primaryGradient: LinearGradient { LinearGradient(colors: [primaryStart, primaryEnd], startPoint: .leading, endPoint: .trailing) }
}
