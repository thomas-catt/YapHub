import Foundation

// MARK: - API Error

nonisolated enum APIError: Error, LocalizedError, Sendable {
    case invalidURL
    case networkError(String)
    case decodingError(String)
    case serverError(Int, String)
    case unauthorized
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let msg):
            return msg
        case .decodingError(let msg):
            return "Failed to parse response: \(msg)"
        case .serverError(_, let msg):
            return msg
        case .unauthorized:
            return "You need to log in to do that"
        case .unknown:
            return "Something went wrong"
        }
    }
}

// MARK: - API Client

nonisolated final class APIClient: Sendable {
    static let shared = APIClient()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        config.httpCookieStorage = HTTPCookieStorage.shared
        self.session = URLSession(configuration: config)
    }

    // MARK: - GET

    func get<T: Decodable & Sendable>(_ path: String) async throws -> T {
        let url = APIConfig.url(path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return try await perform(request)
    }

    // MARK: - POST

    func post<T: Decodable & Sendable>(_ path: String, body: [String: Any]? = nil) async throws -> T {
        let url = APIConfig.url(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        return try await perform(request)
    }

    // MARK: - Perform Request

    private func perform<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError("Could not connect to the server. Please check your connection.")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        if httpResponse.statusCode >= 400 {
            let errorMessage: String
            if let errorBody = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                errorMessage = errorBody.detail ?? errorBody.message ?? "Request failed"
            } else {
                errorMessage = "Request failed with status \(httpResponse.statusCode)"
            }
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}
