import Foundation

nonisolated struct Comment: Codable, Identifiable, Sendable {
    let id: String
    let authorId: String
    let postId: String
    let parentReplyId: String?
    let content: String
    let xCoordinate: Double?
    let yCoordinate: Double?
    let createdAt: String
    let updatedAt: String
    var likesCount: Int
    var repliesCount: Int
    let author: Author?
    var isLiked: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case authorId = "author_id"
        case postId = "post_id"
        case parentReplyId = "parent_reply_id"
        case content
        case xCoordinate = "x_coordinate"
        case yCoordinate = "y_coordinate"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case likesCount = "likes_count"
        case repliesCount = "replies_count"
        case author
        case isLiked = "is_liked"
    }
}

nonisolated struct CreateCommentResponse: Codable, Sendable {
    let commentId: String

    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
    }
}

nonisolated struct CreateReplyResponse: Codable, Sendable {
    let replyId: String

    enum CodingKeys: String, CodingKey {
        case replyId = "reply_id"
    }
}
