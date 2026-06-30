import Foundation

actor APIClient {
    static let shared = APIClient()
    private let baseURL: String
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder: JSONEncoder = { let e = JSONEncoder(); e.keyEncodingStrategy = .convertToSnakeCase; return e }()

    init(baseURL: String = "http://localhost:8000") {
        self.baseURL = baseURL
        let config = URLSessionConfiguration.default; config.timeoutIntervalForRequest = 120
        self.session = URLSession(configuration: config)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetchCards() async throws -> [TarotCard] { try decoder.decode([TarotCard].self, from: try await get("/api/cards")) }
    func fetchSpreads() async throws -> [Spread] { try decoder.decode([Spread].self, from: try await get("/api/spreads")) }

    func createReading(question: String, spreadId: String, cards: [SelectedCard]) async throws -> Reading {
        let body = ReadingRequest(question: question, spreadId: spreadId, cards: cards)
        return try decoder.decode(Reading.self, from: try await post("/api/readings", body: body))
    }

    func sendFollowUp(readingId: String, message: String) async throws -> FollowUpResponse {
        try decoder.decode(FollowUpResponse.self, from: try await post("/api/readings/\(readingId)/follow-up", body: FollowUpBody(message: message)))
    }

    func fetchReadings() async throws -> [Reading] { try decoder.decode([Reading].self, from: try await get("/api/readings")) }

    private func get(_ path: String) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(path)") else { throw APIError.invalidURL }
        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else { throw APIError.badResponse }
        return data
    }

    private func post<T: Encodable>(_ path: String, body: T) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(path)") else { throw APIError.invalidURL }
        var req = URLRequest(url: url); req.httpMethod = "POST"; req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try encoder.encode(body)
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else { throw APIError.badResponse }
        return data
    }
}

enum APIError: Error { case invalidURL, badResponse }
struct ReadingRequest: Codable { let question: String; let spreadId: String; let cards: [SelectedCard] }
struct FollowUpBody: Codable { let message: String }
struct FollowUpResponse: Codable { let readingId: String; let message: String; let response: String? }
