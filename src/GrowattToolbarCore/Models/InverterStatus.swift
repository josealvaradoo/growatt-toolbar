import Foundation
import SwiftUI

/// Real-time telemetry snapshot surfaced by the `/status` endpoint.
/// Each field maps 1:1 to the backend payload — no client-side derivations
/// outside the formatter below.
public struct InverterStatus: Codable, Equatable, Sendable {
    /// State of Charge (SoC) as a percentage (0 to 100).
    public let batterySoC: Int

    /// Active operational state of the inverter battery.
    public let state: InverterState

    /// Inverter output power in kilowatts (kW), always non-negative.
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

    /// Subtitle shown in the power flow badge (e.g. "+3.2 kW grid power").
    public var formattedPowerDescription: String {
        let value = String(format: "%.1f kW", outputPowerKW)
        switch state {
        case .charging:
            return "+\(value) grid power"
        case .discharging:
            return "-\(value) load power"
        }
    }
}
