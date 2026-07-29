import Foundation
import SwiftUI

/// Represents the operating state of the Growatt battery inverter.
/// Only the two states reported by the `/status` endpoint are modeled;
/// add new cases here only when the backend starts emitting them.
public enum InverterState: String, Codable, Sendable, CaseIterable {
    case charging = "CHARGING"
    case discharging = "DISCHARGING"

    public var title: String { rawValue }

    public var iconName: String {
        switch self {
        case .charging: return "bolt.batteryblock.fill"
        case .discharging: return "batteryblock.fill"
        }
    }

    public var accentColor: Color {
        switch self {
        case .charging: return .green
        case .discharging: return .orange
        }
    }
}
