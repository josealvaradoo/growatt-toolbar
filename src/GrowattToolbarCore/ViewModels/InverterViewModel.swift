import Foundation
import SwiftUI
import Observation

/// Main ViewModel coordinating inverter data fetching, background polling, and state representation.
@Observable
@MainActor
public final class InverterViewModel {
    public var status: InverterStatus
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var isMockingData: Bool = true

    private var apiService: GrowattAPIServiceProtocol
    private var mockService: MockGrowattAPIService?
    private var pollingTask: Task<Void, Never>?

    public init(service: GrowattAPIServiceProtocol = MockGrowattAPIService()) {
        self.apiService = service
        self.mockService = service as? MockGrowattAPIService
        self.status = InverterStatus(
            batterySoC: 85,
            state: .charging,
            batteryPowerKW: 3.2,
            solarOutputKW: 1.5,
            gridImportKW: 3.5,
            homeLoadKW: 1.8,
            lastUpdated: Date()
        )
    }

    /// Fetches the latest data from the configured API service.
    public func refreshData() async {
        isLoading = true
        errorMessage = nil

        do {
            let newStatus = try await apiService.fetchInverterStatus()
            self.status = newStatus
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Toggles mock data state (useful for UI testing charging vs discharging).
    public func toggleMockState() {
        if let mock = mockService {
            mock.toggleState()
            Task {
                await refreshData()
            }
        }
    }

    /// Starts periodic auto-refreshing in the background.
    public func startAutoRefresh(intervalSeconds: TimeInterval = 30.0) {
        stopAutoRefresh()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refreshData()
                try? await Task.sleep(nanoseconds: UInt64(intervalSeconds * 1_000_000_000))
            }
        }
    }

    /// Stops periodic auto-refreshing.
    public func stopAutoRefresh() {
        pollingTask?.cancel()
        pollingTask = nil
    }
}
