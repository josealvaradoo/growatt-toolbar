import Foundation
import GrowattToolbarCore

/// Deterministic test double for `GrowattConnectionTesterProtocol`.
///
/// Records the exact draft values each test request used and replays a
/// configured result, so tests can assert that testing used the current
/// normalized draft and that testing never persists anything.
public final class MockConnectionTester: GrowattConnectionTesterProtocol, @unchecked Sendable {
    public var result: Result<InverterStatus, GrowattAPIError>
    public private(set) var requestedKeys: [String] = []
    public private(set) var requestedURLs: [String] = []
    public private(set) var callCount = 0

    public init(
        result: Result<InverterStatus, GrowattAPIError> = .success(
            InverterStatus(batterySoC: 50, state: .charging, outputPowerKW: 1.2)
        )
    ) {
        self.result = result
    }

    public func testConnection(apiKey: String, apiURL: String) async throws -> InverterStatus {
        callCount += 1
        requestedKeys.append(apiKey)
        requestedURLs.append(apiURL)
        return try result.get()
    }
}
