import Foundation

// MARK: - Author (nested in Post response)

nonisolated struct Author: Codable, Identifiable, Sendable {
    let id: String
    let username: String
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username
        case displayName = "display_name"
    }
}

// MARK: - Post

nonisolated struct Post: Codable, Identifiable, Sendable {
    let id: String
    let caption: String
    let image: String
    let authorId: String
    let createdAt: String
    let updatedAt: String
    var likesCount: Int
    var commentsCount: Int
    let author: Author

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case caption
        case image
        case authorId = "author_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case author
    }
}

struct Safe<Base: Decodable>: Decodable {
    let value: Base?
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Base.self)
        } catch {
            print("Failed to decode value: \(error)")
            self.value = nil
        }
    }
}

nonisolated struct PostsResponse: Codable, Sendable {
    let posts: [Post]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let safePosts = try container.decode([Safe<Post>].self, forKey: .posts)
        self.posts = safePosts.compactMap { $0.value }
    }
    
    enum CodingKeys: String, CodingKey {
        case posts
    }
}

// MARK: - Create Post Response

nonisolated struct CreatePostResponse: Codable, Sendable {
    let postId: String

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
    }
}
