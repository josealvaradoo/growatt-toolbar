import Foundation

/// Errors that can occur during `/status` API operations.
public enum GrowattAPIError: Error, Equatable, LocalizedError, Sendable {
    case networkError(String)
    case decodingError(String)
    case unauthorized
    case serverError(statusCode: Int)
    case keychainError(String)

    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network connection failed: \(message)"
        case .decodingError(let details):
            return "Failed to parse response: \(details)"
        case .unauthorized:
            return "Unauthorized API key or token."
        case .serverError(let statusCode):
            return "Server responded with status code \(statusCode)."
        case .keychainError(let message):
            return "Keychain error: \(message)"
        }
    }
}
