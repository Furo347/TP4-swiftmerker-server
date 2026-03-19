import Foundation

enum APIError: Error {
    case notFound(String)
    case conflict(String)
    case validationFailed(String)
    case serverError(String)
    case connectionFailed
    case decodingError(Error)
}

extension APIError {
    var message: String {
        switch self {
        case .notFound(let message):
            return "Error: \(message)"
        case .conflict(let message):
            return "Error: \(message)"
        case .validationFailed(let message):
            return "Error: Validation failed.\n\(message)"
        case .serverError(let message):
            return "Error: \(message)"
        case .connectionFailed:
            return "Error: Could not connect to server at http://localhost:8080.\nMake sure the server is running: swift run in swiftmarket-server/"
        case .decodingError(let error):
            return "Error: Failed to decode server response (\(error.localizedDescription))."
        }
    }
}
