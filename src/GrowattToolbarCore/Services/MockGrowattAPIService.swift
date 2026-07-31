import Foundation

public final class MockGrowattAPIService: GrowattAPIServiceProtocol, Sendable {
    public init() {}

    public func fetchInverterStatus() async throws -> InverterStatus {
        InverterStatus(
            batterySoC: 65,
            state: .charging,
            outputPowerKW: 2.5
        )
    }
}
