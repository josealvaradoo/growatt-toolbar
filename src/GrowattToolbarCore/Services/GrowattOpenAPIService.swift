import Foundation

/// Real Growatt OpenAPI client performing REST requests to fetch telemetry data.
public final class GrowattOpenAPIService: GrowattAPIServiceProtocol, Sendable {
    private let baseURL: URL
    private let apiToken: String
    private let deviceSN: String
    private let session: URLSession

    public init(
        baseURLString: String = "https://openapi.growatt.com/v1",
        apiToken: String = "",
        deviceSN: String = "",
        session: URLSession = .shared
    ) {
        self.baseURL = URL(string: baseURLString) ?? URL(string: "https://openapi.growatt.com/v1")!
        self.apiToken = apiToken
        self.deviceSN = deviceSN
        self.session = session
    }

    public func fetchInverterStatus() async throws -> InverterStatus {
        guard !apiToken.isEmpty, !deviceSN.isEmpty else {
            // Fallback: If credentials are empty, return fallback telemetry
            throw GrowattAPIError.unauthorized
        }

        let endpoint = baseURL.appendingPathComponent("device/inverter/data")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GrowattAPIError.networkError("Invalid HTTP response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw GrowattAPIError.unauthorized
            }
            throw GrowattAPIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(GrowattInverterResponseDTO.self, from: data)
            return decoded.toDomainModel()
        } catch {
            throw GrowattAPIError.decodingError(error.localizedDescription)
        }
    }
}

// MARK: - DTOs

struct GrowattInverterResponseDTO: Decodable {
    let soc: Int?
    let pcharge: Double?
    let pdischarge: Double?
    let pppv: Double?
    let pgrid: Double?
    let pload: Double?

    func toDomainModel() -> InverterStatus {
        let batterySoC = soc ?? 0
        let chargePower = pcharge ?? 0.0
        let dischargePower = pdischarge ?? 0.0

        let state: InverterState
        let batteryPowerKW: Double

        if chargePower > 0 {
            state = .charging
            batteryPowerKW = chargePower
        } else if dischargePower > 0 {
            state = .discharging
            batteryPowerKW = -dischargePower
        } else {
            state = .idle
            batteryPowerKW = 0.0
        }

        return InverterStatus(
            batterySoC: batterySoC,
            state: state,
            batteryPowerKW: batteryPowerKW,
            solarOutputKW: pppv ?? 0.0,
            gridImportKW: pgrid ?? 0.0,
            homeLoadKW: pload ?? 0.0,
            lastUpdated: Date()
        )
    }
}
