import Foundation
import GrowattToolbarCore

print("🧪 Running Growatt Toolbar Unit Test Suite...")

// 1. InverterStatus & State Tests
print("  ▸ Testing InverterState metadata...")
assert(InverterState.charging.title == "CHARGING")
assert(InverterState.charging.iconName == "bolt.batteryblock.fill")
assert(InverterState.discharging.title == "DISCHARGING")
assert(InverterState.discharging.iconName == "batteryblock.fill")
assert(InverterState.idle.title == "IDLE")

print("  ▸ Testing Battery SoC bounds...")
let statusOverflow = InverterStatus(batterySoC: 120, state: .charging, batteryPowerKW: 2.0)
assert(statusOverflow.batterySoC == 100)

let statusUnderflow = InverterStatus(batterySoC: -10, state: .discharging, batteryPowerKW: -1.0)
assert(statusUnderflow.batterySoC == 0)

print("  ▸ Testing Formatted Power Descriptions...")
let statusCharging = InverterStatus(batterySoC: 85, state: .charging, batteryPowerKW: 3.2)
assert(statusCharging.formattedPowerDescription.contains("+3.2 kW"))

let statusDischarging = InverterStatus(batterySoC: 45, state: .discharging, batteryPowerKW: -1.8)
assert(statusDischarging.formattedPowerDescription.contains("-1.8 kW"))

// 2. Growatt API Service Tests
Task {
    print("  ▸ Testing Mock Service...")
    let mock = MockGrowattAPIService()
    let result = try await mock.fetchInverterStatus()
    assert(result.batterySoC == 85)
    assert(result.state == .charging)
    assert(result.batteryPowerKW == 3.2)

    print("  ▸ Testing Mock Service State Toggle...")
    mock.toggleState()
    assert(mock.mockStatus.state == .discharging)
    assert(mock.mockStatus.batteryPowerKW < 0)

    mock.toggleState()
    assert(mock.mockStatus.state == .charging)
    assert(mock.mockStatus.batteryPowerKW > 0)

    print("  ▸ Testing Mock Service Errors...")
    let mockErrorService = MockGrowattAPIService(shouldThrowError: true)
    do {
        _ = try await mockErrorService.fetchInverterStatus()
        fatalError("Expected error but fetch succeeded")
    } catch {
        assert(error is GrowattAPIError)
    }

    // 3. ViewModel Tests
    await MainActor.run {
        print("  ▸ Testing ViewModel Initialization & Refresh...")
        let viewModel = InverterViewModel(service: mock)
        assert(viewModel.status.batterySoC == 85)
        assert(viewModel.isLoading == false)
        assert(viewModel.errorMessage == nil)
    }

    print("\n✅ All unit tests passed successfully!")
    exit(0)
}

RunLoop.main.run(until: Date().addingTimeInterval(3))
