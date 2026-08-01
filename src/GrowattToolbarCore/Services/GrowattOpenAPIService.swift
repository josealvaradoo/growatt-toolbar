import Foundation

/// Status API client fetching inverter telemetry from a local `GET /status`
/// endpoint authenticated with an `x-api-key` header.
public final class GrowattOpenAPIService: GrowattAPIServiceProtocol, Sendable {
    private let baseURL: URL
    private let apiToken: String
    private let session: URLSession

    /// Constructs a service for the given base URL and API token.
    ///
    /// Throws `GrowattAPIError.networkError` when the base URL string is
    /// missing, unparseable, lacks an `http`/`https` scheme, or has no host,
    /// so invalid draft URLs become typed failures instead of runtime traps.
    /// The API token is never included in the thrown error.
    public init(
        baseURLString: String,
        apiToken: String,
        session: URLSession = .shared
    ) throws {
        let trimmed = baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), !trimmed.isEmpty else {
            throw GrowattAPIError.networkError("Invalid or missing API URL")
        }
        guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            throw GrowattAPIError.networkError("API URL must use http or https")
        }
        guard let host = url.host, !host.isEmpty else {
            throw GrowattAPIError.networkError("API URL must include a host")
        }
        self.baseURL = url
        self.apiToken = apiToken
        self.session = session
    }

    public func fetchInverterStatus() async throws -> InverterStatus {
        guard !apiToken.isEmpty else { throw GrowattAPIError.unauthorized }

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
            return try JSONDecoder().decode(StatusResponseDTO.self, from: data).toDomainModel()
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
        let outputPower: Double

        enum CodingKeys: String, CodingKey {
            case level
            case isCharging = "is_charging"
            case outputPower = "output_power"
        }
    }

    func toDomainModel() -> InverterStatus {
        InverterStatus(
            batterySoC: data.level,
            state: data.isCharging ? .charging : .discharging,
            outputPowerKW: data.outputPower / 1000.0,
            lastUpdated: Date()
        )
    }
}
