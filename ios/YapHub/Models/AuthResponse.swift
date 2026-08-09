import Foundation

nonisolated struct AuthResponse: Codable, Sendable {
    let userId: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}

nonisolated struct LogoutResponse: Codable, Sendable {
    let action: String
}

nonisolated struct ErrorResponse: Codable, Sendable {
    let detail: String?
    let message: String?
}
