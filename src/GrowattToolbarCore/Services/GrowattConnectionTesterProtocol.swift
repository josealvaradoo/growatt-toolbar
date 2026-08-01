import Foundation

/// Injectable seam that verifies draft credentials against the inverter's
/// `/status` endpoint without persisting anything.
///
/// The settings flow uses this instead of constructing a
/// `GrowattOpenAPIService` directly, keeping SwiftUI and the view model
/// independent of transport construction and making connection tests
/// deterministic with a mock.
public protocol GrowattConnectionTesterProtocol: Sendable {
    /// Performs a `/status` request using the given draft API key and URL.
    /// Throws a typed `GrowattAPIError` on failure. Never writes to Keychain,
    /// UserDefaults, or any persistence layer.
    func testConnection(apiKey: String, apiURL: String) async throws -> InverterStatus
}
