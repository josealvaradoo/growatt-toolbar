import Foundation

/// Service protocol defining interaction with Growatt Inverter API.
public protocol GrowattAPIServiceProtocol: Sendable {
    /// Fetches the latest inverter telemetry data.
    func fetchInverterStatus() async throws -> InverterStatus
}
