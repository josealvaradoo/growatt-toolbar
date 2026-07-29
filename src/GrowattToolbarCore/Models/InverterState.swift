import Foundation
import SwiftUI

/// Represents the operating state of the Growatt battery inverter.
public enum InverterState: String, Codable, Sendable, CaseIterable {
    case charging = "CHARGING"
    case discharging = "DISCHARGING"
    case idle = "IDLE"
    case unknown = "UNKNOWN"

    /// User-facing display title.
    public var title: String {
        rawValue
    }

    /// System image name for the corresponding state.
    public var iconName: String {
        switch self {
        case .charging:
            return "bolt.batteryblock.fill"
        case .discharging:
            return "batteryblock.fill"
        case .idle:
            return "minus.square.fill"
        case .unknown:
            return "questionmark.square.fill"
        }
    }

    /// Primary status badge background color / glow color.
    public var accentColor: Color {
        switch self {
        case .charging:
            return Color.green
        case .discharging:
            return Color.orange
        case .idle:
            return Color.blue
        case .unknown:
            return Color.gray
        }
    }
}
