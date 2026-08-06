import Foundation

public final class MockGrowattAPIService: GrowattAPIServiceProtocol, Sendable {
    public init() {}

    public func fetchInverterStatus(bypassCache: Bool = false) async throws -> InverterStatus {
        _ = bypassCache
        return InverterStatus(
            batterySoC: 65,
            state: .charging,
            outputPowerKW: 2.5
        )
    }
}
