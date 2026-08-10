import Foundation

nonisolated struct APIConfig {
    static var baseURL: String {
        if let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
           let apiUrl = plist["API_BASE_URL"] as? String {
            return apiUrl
        }
        print("Warning: Config.plist not found or missing API_BASE_URL. Using fallback.")
        return "http://localhost:8000"
    }

    static func url(_ path: String) -> URL {
        URL(string: "\(baseURL)\(path)")!
    }
}
