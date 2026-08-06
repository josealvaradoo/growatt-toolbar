import Foundation

/// Service protocol defining interaction with Growatt Inverter API.
public protocol GrowattAPIServiceProtocol: Sendable {
    /// Fetches the latest inverter telemetry data.
    ///
    /// - Parameter bypassCache: When `true`, the implementation appends a
    ///   `cache=false` query item so the upstream serves a fresh reading
    ///   instead of a cached one. Manual refresh affordances should pass
    ///   `true`; background polling should pass `false`.
    func fetchInverterStatus(bypassCache: Bool) async throws -> InverterStatus

    /// Convenience overload that fetches with the upstream cache enabled
    /// (the default behavior for background polling and connection tests).
    func fetchInverterStatus() async throws -> InverterStatus
}

extension GrowattAPIServiceProtocol {
    public func fetchInverterStatus() async throws -> InverterStatus {
        try await fetchInverterStatus(bypassCache: false)
    }
}
