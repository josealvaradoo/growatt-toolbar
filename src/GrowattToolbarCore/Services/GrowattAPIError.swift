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

    /// Safe, user-facing message for this error.
    ///
    /// The settings flow renders exactly this copy and nothing else, so
    /// technical details, status codes, and credential values never reach
    /// the UI, accessibility announcements, or logs.
    public var safeUserMessage: String {
        switch self {
        case .unauthorized:
            return "The API key was rejected. Check the key and try again."
        case .networkError:
            return "The API could not be reached. Check the URL and network connection."
        case .decodingError:
            return "The endpoint returned an unexpected response."
        case .serverError:
            return "The API server is unavailable right now. Try again later."
        case .keychainError:
            return "The credentials could not be saved securely. Try again."
        }
    }
}
