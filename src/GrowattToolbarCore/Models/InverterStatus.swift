import Foundation

/// Real-time telemetry snapshot surfaced by the `/status` endpoint.
/// Each field maps 1:1 to the backend payload — no client-side derivations.
public struct InverterStatus: Codable, Equatable, Sendable {
    /// State of Charge (SoC) as a percentage (0 to 100).
    public let batterySoC: Int

    /// Active operational state of the inverter battery.
    public let state: InverterState

    /// Home consumption in kilowatts, always non-negative. The backend
    /// reports `output_power` as the watt draw the home is currently
    /// drawing from the inverter / grid — *consumption*, not generation.
    /// This value is independent of the battery's charging direction.
    /// Rendered inline in the two-column hero row ("Home Load" label);
    /// the battery state badge shows only the state, not this value.
    public let outputPowerKW: Double

    /// Timestamp of when the metrics were retrieved.
    public let lastUpdated: Date

    public init(
        batterySoC: Int,
        state: InverterState,
        outputPowerKW: Double,
        lastUpdated: Date = Date()
    ) {
        self.batterySoC = min(max(batterySoC, 0), 100)
        self.state = state
        self.outputPowerKW = max(outputPowerKW, 0)
        self.lastUpdated = lastUpdated
    }
}
