import Foundation
import SwiftUI

@Observable
final class FeedViewModel {
    var posts: [Post] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var hasLoaded: Bool = false

    private let postService = PostService()
    private let likeService = LikeService()

    func loadPosts() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await postService.fetchPosts()
            // Sort by newest first (created_at is ISO string, lexicographic sort works)
            posts = fetched.sorted { $0.createdAt > $1.createdAt }
            hasLoaded = true
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load posts"
        }

        isLoading = false
    }

    func toggleLike(for postId: String) async {
        do {
            let response = try await likeService.toggleLike(target: "post", targetId: postId)
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].likesCount = response.likesCount
            }
        } catch {
            // Silently fail on like toggle errors
        }
    }

    func refreshAfterCreate() async {
        await loadPosts()
    }
}
