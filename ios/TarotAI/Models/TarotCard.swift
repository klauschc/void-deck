import Foundation

struct TarotCard: Codable, Identifiable {
    let id: String
    let nameEn: String
    let nameZh: String
    let arcana: String
    let suit: String?
    let number: Int
    let uprightMeaning: String
    let reversedMeaning: String
    let loveMeaning: String?
    let careerMeaning: String?
    let financeMeaning: String?
    let spiritualMeaning: String?
    let advice: String?
    let warning: String?
    let keywordsUpright: String?
    let keywordsReversed: String?
    let description: String?
}
