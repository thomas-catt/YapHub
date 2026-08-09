import Foundation

nonisolated struct LikeResponse: Codable, Sendable {
    let action: String       // "like" or "unlike"
    let likesCount: Int

    enum CodingKeys: String, CodingKey {
        case action
        case likesCount = "likes_count"
    }
}
