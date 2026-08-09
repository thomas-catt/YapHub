import Foundation

nonisolated struct LikeService: Sendable {
    private let client = APIClient.shared

    func toggleLike(target: String, targetId: String) async throws -> LikeResponse {
        return try await client.post("/likes/toggle", body: [
            "target": target,
            "target_id": targetId
        ])
    }
}
