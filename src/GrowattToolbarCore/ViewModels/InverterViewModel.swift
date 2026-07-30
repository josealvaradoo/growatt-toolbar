import Foundation
import Observation

/// ViewModel coordinating inverter data fetching and background polling.
///
/// Owns the four-state trust layer surfaced by the popover:
///
/// - `.awaiting` — first poll not yet completed
/// - `.live` — last poll succeeded and data is fresh
/// - `.stale` — last poll succeeded but data is older than the freshness window
/// - `.error` — last poll failed
///
/// The view model serializes concurrent `refreshData()` invocations (the
/// polling loop and the manual refresh button share a single in-flight task)
/// and cancels its background work in `deinit` so no orphan timers survive
/// the view model's lifetime.
@Observable
@MainActor
public final class InverterViewModel {
    public var status: InverterStatus
    public var isLoading: Bool = false

    /// Typed error from the most recent poll. `nil` while awaiting the first
    /// reading or after a successful poll. Persisted (not cleared on success
    /// of *any* subsequent poll) so the popover can show a specific recovery
    /// message for the last failure the user actually saw.
    public var error: GrowattAPIError?

    /// `true` once the first successful poll has produced a `status`. While
    /// `false` the popover renders a composed placeholder instead of
    /// `0% / .charging / 0 kW` (which would otherwise look like a critical
    /// state).
    public private(set) var hasReceivedFirstReading: Bool = false

    /// How long a `live` reading stays `live` before being reclassified as
    /// `stale`. Default 1.5× the 120s polling interval.
    public let freshnessWindow: TimeInterval

    private let apiService: GrowattAPIServiceProtocol
    private var pollingTask: Task<Void, Never>?
    private var inFlightRefresh: Task<Void, Never>?

    public init(
        service: GrowattAPIServiceProtocol = GrowattOpenAPIService(),
        freshnessWindow: TimeInterval = 180
    ) {
        self.apiService = service
        self.freshnessWindow = freshnessWindow
        self.status = InverterStatus(
            batterySoC: 0,
            state: .charging,
            outputPowerKW: 0
        )
    }

    deinit {
        // The class is `@MainActor`; in practice the deinit runs on the main
        // thread because all references are main-actor-held. `assumeIsolated`
        // lets us cancel the tasks from the deinit while keeping the
        // compiler's actor-isolation checker happy. If the deinit ever ran
        // off the main actor, this would trap — that's the correct
        // diagnostic, because the tasks themselves are main-actor-bound.
        MainActor.assumeIsolated {
            pollingTask?.cancel()
            inFlightRefresh?.cancel()
        }
    }

    // MARK: - Trust state

    /// Category of trust the popover should render right now. Re-evaluated by
    /// the view each tick (typically once per second via `TimelineView`).
    public var freshness: Freshness {
        if error != nil { return .error }
        if !hasReceivedFirstReading { return .awaiting }
        if Date().timeIntervalSince(status.lastUpdated) > freshnessWindow {
            return .stale
        }
        return .live
    }

    /// Seconds since the most recent successful reading. `nil` before the
    /// first poll. Drives the inline "Updated Nm ago" / "Last reading Nm ago"
    /// copy.
    public var secondsSinceLastUpdate: TimeInterval? {
        guard hasReceivedFirstReading else { return nil }
        return Date().timeIntervalSince(status.lastUpdated)
    }

    // MARK: - Refresh

    /// Triggers a refresh. Concurrent callers (the polling loop and the
    /// manual refresh button) share a single in-flight task, so the second
    /// caller awaits the first rather than racing it.
    public func refreshData() async {
        if let inFlight = inFlightRefresh {
            await inFlight.value
            return
        }
        let task = Task { [weak self] in
            await self?.performRefresh()
            return
        }
        inFlightRefresh = task
        await task.value
        inFlightRefresh = nil
    }

    private func performRefresh() async {
        isLoading = true
        do {
            self.status = try await apiService.fetchInverterStatus()
            self.error = nil
            self.hasReceivedFirstReading = true
        } catch let typedError as GrowattAPIError {
            self.error = typedError
        } catch {
            // Fallback for any non-typed error (defensive: GrowattOpenAPIService
            // already wraps everything, but a custom test service might not).
            self.error = .networkError(error.localizedDescription)
        }
        isLoading = false
    }

    // MARK: - Polling

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
