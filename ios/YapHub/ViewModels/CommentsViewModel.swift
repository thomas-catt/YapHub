import Foundation
import SwiftUI

@Observable
final class CommentsViewModel {
    var comments: [Comment] = []
    var repliesByCommentId: [String: [Comment]] = [:]
    var expandedReplies: Set<String> = []
    var isLoading: Bool = false
    var errorMessage: String?
    var highlightedCommentId: String?
    var filterToCommentId: String?

    var displayComments: [Comment] {
        if let filterId = filterToCommentId {
            return comments.filter { $0.id == filterId }
        }
        return comments
    }

    // For inline reply
    var replyingToCommentId: String?
    var replyText: String = ""
    var isSubmittingReply: Bool = false

    // For add comment sheet
    var isAddingComment: Bool = false
    var newCommentText: String = ""
    var selectedPoint: CGPoint?
    var isSubmittingComment: Bool = false

    let post: Post

    private let commentService = CommentService()
    private let likeService = LikeService()

    init(post: Post) {
        self.post = post
    }

    // MARK: - Fetch Comments

    func loadComments() async {
        isLoading = true
        errorMessage = nil

        do {
            comments = try await commentService.fetchComments(postId: post.id)
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load comments"
        }

        isLoading = false
    }

    // MARK: - Fetch Replies

    func loadReplies(for commentId: String) async {
        do {
            let replies = try await commentService.fetchReplies(commentId: commentId)
            repliesByCommentId[commentId] = replies
            expandedReplies.insert(commentId)
        } catch {
            // Silently fail
        }
    }

    func toggleReplies(for commentId: String) async {
        if expandedReplies.contains(commentId) {
            expandedReplies.remove(commentId)
        } else {
            await loadReplies(for: commentId)
        }
    }

    // MARK: - Create Comment

    func submitComment() async {
        guard let point = selectedPoint, !newCommentText.isEmpty else { return }

        isSubmittingComment = true

        do {
            _ = try await commentService.createComment(
                postId: post.id,
                content: newCommentText,
                x: Double(point.x),
                y: Double(point.y)
            )
            newCommentText = ""
            selectedPoint = nil
            isAddingComment = false
            await loadComments()
        } catch {
            errorMessage = "Failed to post comment"
        }

        isSubmittingComment = false
    }

    // MARK: - Create Reply

    func startReply(to commentId: String) {
        replyingToCommentId = commentId
        replyText = ""
    }

    func cancelReply() {
        replyingToCommentId = nil
        replyText = ""
    }

    func submitReply() async {
        guard let commentId = replyingToCommentId, !replyText.isEmpty else { return }

        isSubmittingReply = true

        let optimisticText = replyText
        let optimisticId = UUID().uuidString
        let optimisticComment = Comment(
            id: optimisticId,
            authorId: "temp",
            postId: post.id,
            parentReplyId: commentId,
            content: optimisticText,
            xCoordinate: nil,
            yCoordinate: nil,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            likesCount: 0,
            repliesCount: 0,
            author: Author(id: "temp", username: "sending...", displayName: "Sending...")
        )

        // Optimistically add to replies
        var currentReplies = repliesByCommentId[commentId] ?? []
        currentReplies.append(optimisticComment)
        repliesByCommentId[commentId] = currentReplies
        expandedReplies.insert(commentId)
        
        // Clear input early
        replyText = ""
        replyingToCommentId = nil

        do {
            _ = try await commentService.createReply(
                commentId: commentId,
                content: optimisticText
            )
            // Refresh replies to get the real comment with correct ID and author
            await loadReplies(for: commentId)
        } catch {
            errorMessage = "Failed to post reply"
            // Revert optimistic update
            var revertedReplies = repliesByCommentId[commentId] ?? []
            revertedReplies.removeAll(where: { $0.id == optimisticId })
            repliesByCommentId[commentId] = revertedReplies
        }

        isSubmittingReply = false
    }

    // MARK: - Like Comment

    func toggleCommentLike(commentId: String) async {
        do {
            let response = try await likeService.toggleLike(target: "comment", targetId: commentId)
            if let index = comments.firstIndex(where: { $0.id == commentId }) {
                comments[index].likesCount = response.likesCount
            }
            // Also check replies
            for (parentId, replies) in repliesByCommentId {
                if let index = replies.firstIndex(where: { $0.id == commentId }) {
                    repliesByCommentId[parentId]?[index].likesCount = response.likesCount
                }
            }
        } catch {
            // Silently fail
        }
    }
}
