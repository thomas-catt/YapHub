import Foundation

nonisolated struct PostService: Sendable {
    private let client = APIClient.shared

    func fetchPosts() async throws -> [Post] {
        let response: PostsResponse = try await client.get("/posts/")
        return response.posts
    }

    func createPost(caption: String, imageURL: String) async throws -> CreatePostResponse {
        return try await client.post("/posts/create", body: [
            "caption": caption,
            "image": imageURL
        ])
    }
}
