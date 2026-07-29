import Foundation
import Observation

/// ViewModel coordinating inverter data fetching and background polling.
@Observable
@MainActor
public final class InverterViewModel {
    public var status: InverterStatus
    public var isLoading: Bool = false
    public var errorMessage: String?

    private let apiService: GrowattAPIServiceProtocol
    private var pollingTask: Task<Void, Never>?

    public init(service: GrowattAPIServiceProtocol = GrowattOpenAPIService()) {
        self.apiService = service
        self.status = InverterStatus(
            batterySoC: 0,
            state: .charging,
            outputPowerKW: 0
        )
    }

    public func refreshData() async {
        isLoading = true
        errorMessage = nil
        do {
            self.status = try await apiService.fetchInverterStatus()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func startAutoRefresh(intervalSeconds: TimeInterval = 120.0) {
        stopAutoRefresh()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refreshData()
                try? await Task.sleep(nanoseconds: UInt64(intervalSeconds * 1_000_000_000))
            }
        }
    }

    public func stopAutoRefresh() {
        pollingTask?.cancel()
        pollingTask = nil
    }
}
