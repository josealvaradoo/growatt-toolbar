import Foundation

/// Errors that can occur during Growatt API operations.
public enum GrowattAPIError: Error, Equatable, LocalizedError, Sendable {
    case invalidURL
    case networkError(String)
    case decodingError(String)
    case unauthorized
    case serverError(statusCode: Int)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL requested."
        case .networkError(let message):
            return "Network connection failed: \(message)"
        case .decodingError(let details):
            return "Failed to parse Growatt response: \(details)"
        case .unauthorized:
            return "Unauthorized API key or token."
        case .serverError(let statusCode):
            return "Server responded with status code \(statusCode)."
        }
    }
}
