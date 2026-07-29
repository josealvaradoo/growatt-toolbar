import Foundation

/// Mock API service delivering predictable telemetry data for offline testing, UI previews, and dev mode.
public final class MockGrowattAPIService: GrowattAPIServiceProtocol, @unchecked Sendable {
    public var mockStatus: InverterStatus
    public var shouldThrowError: Bool
    public var mockError: GrowattAPIError

    public init(
        mockStatus: InverterStatus = InverterStatus(
            batterySoC: 85,
            state: .charging,
            batteryPowerKW: 3.2,
            solarOutputKW: 1.5,
            gridImportKW: 3.5,
            homeLoadKW: 1.8,
            lastUpdated: Date()
        ),
        shouldThrowError: Bool = false,
        mockError: GrowattAPIError = .networkError("Mock Connection Failed")
    ) {
        self.mockStatus = mockStatus
        self.shouldThrowError = shouldThrowError
        self.mockError = mockError
    }

    public func fetchInverterStatus() async throws -> InverterStatus {
        // Simulate a minor network latency
        try await Task.sleep(nanoseconds: 200_000_000)

        if shouldThrowError {
            throw mockError
        }

        // Return status updated to current time
        return InverterStatus(
            batterySoC: mockStatus.batterySoC,
            state: mockStatus.state,
            batteryPowerKW: mockStatus.batteryPowerKW,
            solarOutputKW: mockStatus.solarOutputKW,
            gridImportKW: mockStatus.gridImportKW,
            homeLoadKW: mockStatus.homeLoadKW,
            lastUpdated: Date()
        )
    }

    /// Helper to toggle between charging and discharging state for testing transitions.
    public func toggleState() {
        if mockStatus.state == .charging {
            mockStatus = InverterStatus(
                batterySoC: max(mockStatus.batterySoC - 5, 10),
                state: .discharging,
                batteryPowerKW: -2.4,
                solarOutputKW: 0.2,
                gridImportKW: 0.0,
                homeLoadKW: 2.2,
                lastUpdated: Date()
            )
        } else {
            mockStatus = InverterStatus(
                batterySoC: min(mockStatus.batterySoC + 5, 100),
                state: .charging,
                batteryPowerKW: 3.2,
                solarOutputKW: 1.5,
                gridImportKW: 3.5,
                homeLoadKW: 1.8,
                lastUpdated: Date()
            )
        }
    }
}
