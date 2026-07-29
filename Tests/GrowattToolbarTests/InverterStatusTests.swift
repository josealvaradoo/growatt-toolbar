import XCTest
import Foundation
import SwiftUI
@testable import GrowattToolbarCore

final class InverterStatusTests: XCTestCase {

    func testInverterStateMetadata() {
        XCTAssertEqual(InverterState.charging.title, "CHARGING")
        XCTAssertEqual(InverterState.charging.iconName, "bolt.batteryblock.fill")
        XCTAssertEqual(InverterState.discharging.title, "DISCHARGING")
        XCTAssertEqual(InverterState.discharging.iconName, "batteryblock.fill")
        XCTAssertEqual(InverterState.idle.title, "IDLE")
    }

    func testBatterySoCBounds() {
        let statusOverflow = InverterStatus(batterySoC: 120, state: .charging, batteryPowerKW: 2.0)
        XCTAssertEqual(statusOverflow.batterySoC, 100)

        let statusUnderflow = InverterStatus(batterySoC: -10, state: .discharging, batteryPowerKW: -1.0)
        XCTAssertEqual(statusUnderflow.batterySoC, 0)
    }

    func testFormattedPowerDescription() {
        let statusCharging = InverterStatus(batterySoC: 85, state: .charging, batteryPowerKW: 3.2)
        XCTAssertTrue(statusCharging.formattedPowerDescription.contains("+3.2 kW"))

        let statusDischarging = InverterStatus(batterySoC: 45, state: .discharging, batteryPowerKW: -1.8)
        XCTAssertTrue(statusDischarging.formattedPowerDescription.contains("-1.8 kW"))
    }
}
