import Foundation

/// Status API client fetching inverter telemetry from a local `GET /status` endpoint
/// authenticated with an `x-api-key` header.
public final class GrowattOpenAPIService: GrowattAPIServiceProtocol, Sendable {
    private let baseURL: URL
    private let apiToken: String
    private let session: URLSession

    public init(
        baseURLString: String = "http://localhost:3000",
        apiToken: String = "",
        session: URLSession = .shared
    ) {
        self.baseURL = URL(string: baseURLString) ?? URL(string: "http://localhost:3000")!
        self.apiToken = apiToken
        self.session = session
    }

    public func fetchInverterStatus() async throws -> InverterStatus {
        guard !apiToken.isEmpty else {
            throw GrowattAPIError.unauthorized
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("status"))
        request.httpMethod = "GET"
        request.addValue(apiToken, forHTTPHeaderField: "x-api-key")
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
            let decoded = try JSONDecoder().decode(StatusResponseDTO.self, from: data)
            return decoded.toDomainModel()
        } catch {
            throw GrowattAPIError.decodingError(error.localizedDescription)
        }
    }
}

// MARK: - DTOs

struct StatusResponseDTO: Decodable {
    let data: StatusData

    struct StatusData: Decodable {
        let level: Int
        let isCharging: Bool
        let consumptionWatts: Double

        enum CodingKeys: String, CodingKey {
            case level
            case isCharging = "is_charging"
            case consumptionWatts = "consumption_watts"
        }
    }

    func toDomainModel() -> InverterStatus {
        let powerKW = data.consumptionWatts / 1000.0
        let state: InverterState = data.isCharging ? .charging : .discharging
        let batteryPowerKW = data.isCharging ? powerKW : -powerKW

        return InverterStatus(
            batterySoC: data.level,
            state: state,
            batteryPowerKW: batteryPowerKW,
            lastUpdated: Date()
        )
    }
}
