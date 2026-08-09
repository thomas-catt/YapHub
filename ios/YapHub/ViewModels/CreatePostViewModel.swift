import Foundation
import SwiftUI

@Observable
final class CreatePostViewModel {
    var imageURL: String = ""
    var caption: String = ""
    var isSubmitting: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    var didSubmitSuccessfully: Bool = false

    private let postService = PostService()

    var formValid: Bool {
        !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func submit() async {
        guard formValid else {
            errorMessage = "Please provide both an image URL and a caption"
            showError = true
            return
        }

        isSubmitting = true
        errorMessage = nil

        do {
            _ = try await postService.createPost(
                caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
                imageURL: imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            didSubmitSuccessfully = true
            reset()
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = "Failed to create post"
            showError = true
        }

        isSubmitting = false
    }

    func reset() {
        imageURL = ""
        caption = ""
        errorMessage = nil
        showError = false
    }
}
