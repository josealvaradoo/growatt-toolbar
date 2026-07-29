import Foundation

/// Model representing real-time telemetry metrics from the Growatt inverter.
public struct InverterStatus: Codable, Equatable, Sendable {
    /// State of Charge (SoC) as a percentage (0 to 100).
    public let batterySoC: Int

    /// Active operational state of the inverter battery.
    public let state: InverterState

    /// Battery power in kilowatts (kW). Positive when charging, negative when discharging.
    public let batteryPowerKW: Double

    /// Solar generation power output in kilowatts (kW).
    public let solarOutputKW: Double

    /// Grid power import in kilowatts (kW).
    public let gridImportKW: Double

    /// Household consumption load in kilowatts (kW).
    public let homeLoadKW: Double

    /// Timestamp of when the metrics were retrieved.
    public let lastUpdated: Date

    public init(
        batterySoC: Int,
        state: InverterState,
        batteryPowerKW: Double,
        solarOutputKW: Double = 0.0,
        gridImportKW: Double = 0.0,
        homeLoadKW: Double = 0.0,
        lastUpdated: Date = Date()
    ) {
        self.batterySoC = min(max(batterySoC, 0), 100)
        self.state = state
        self.batteryPowerKW = batteryPowerKW
        self.solarOutputKW = solarOutputKW
        self.gridImportKW = gridImportKW
        self.homeLoadKW = homeLoadKW
        self.lastUpdated = lastUpdated
    }

    /// Formatted battery power string (e.g., "+3.2 kW grid power" or "-1.5 kW load power").
    public var formattedPowerDescription: String {
        let absValue = String(format: "%.1f kW", abs(batteryPowerKW))
        switch state {
        case .charging:
            return "+\(absValue) grid power"
        case .discharging:
            return "-\(absValue) load power"
        case .idle:
            return "0.0 kW idle"
        case .unknown:
            return "-- kW"
        }
    }
}
