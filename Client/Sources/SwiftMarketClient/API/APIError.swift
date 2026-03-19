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
            return "Not found: \(message)"
        case .conflict(let message):
            return "Conflict: \(message)"
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .connectionFailed:
            return "Error: Could not connect to server at http://localhost:8080.\nMake sure the server is running: swift run in swiftmarket-server/"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
