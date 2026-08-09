import Foundation

nonisolated struct AuthService: Sendable {
    private let client = APIClient.shared

    func register(username: String, password: String, displayName: String) async throws -> AuthResponse {
        return try await client.post("/users/register", body: [
            "username": username,
            "password": password,
            "display_name": displayName
        ])
    }

    func login(username: String, password: String) async throws -> AuthResponse {
        return try await client.post("/users/login", body: [
            "username": username,
            "password": password
        ])
    }

    func logout() async throws -> LogoutResponse {
        return try await client.post("/users/logout")
    }
}
