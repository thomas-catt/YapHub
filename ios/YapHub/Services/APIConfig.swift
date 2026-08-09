import Foundation

nonisolated struct APIConfig {
    static let baseURL = "http://localhost:8000"

    static func url(_ path: String) -> URL {
        URL(string: "\(baseURL)\(path)")!
    }
}
