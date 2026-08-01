import Foundation

/// Default connection tester used by the settings flow.
///
/// Builds a temporary `GrowattOpenAPIService` from the draft credentials,
/// performs a single `/status` request, and discards the service. Nothing is
/// persisted: no Keychain writes, no UserDefaults, no onboarding state.
public struct GrowattConnectionTester: GrowattConnectionTesterProtocol {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func testConnection(apiKey: String, apiURL: String) async throws -> InverterStatus {
        let service = try GrowattOpenAPIService(
            baseURLString: apiURL,
            apiToken: apiKey,
            session: session
        )
        return try await service.fetchInverterStatus()
    }
}
