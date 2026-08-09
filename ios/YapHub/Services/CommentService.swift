import Foundation

nonisolated struct CommentService: Sendable {
    private let client = APIClient.shared

    func fetchComments(postId: String) async throws -> [Comment] {
        return try await client.get("/posts/\(postId)/comments")
    }

    func createComment(postId: String, content: String, x: Double, y: Double) async throws -> CreateCommentResponse {
        return try await client.post("/posts/\(postId)/comments", body: [
            "content": content,
            "x_coordinate": x,
            "y_coordinate": y
        ])
    }

    func fetchReplies(commentId: String) async throws -> [Comment] {
        return try await client.get("/comments/\(commentId)/replies")
    }

    func createReply(commentId: String, content: String) async throws -> CreateReplyResponse {
        return try await client.post("/comments/\(commentId)/replies", body: [
            "content": content
        ])
    }
}
