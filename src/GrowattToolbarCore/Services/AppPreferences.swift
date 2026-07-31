import Foundation

@MainActor
public final class AppPreferences {
    private var cachedApiKey: String?
    private var apiKeyLoaded = false

    public var apiKey: String {
        if !apiKeyLoaded {
            cachedApiKey = loadApiKey()
            if cachedApiKey != nil, !(cachedApiKey ?? "").isEmpty {
                apiKeyLoaded = true
            }
        }
        return cachedApiKey ?? ""
    }

    public var apiURL: String {
        if let url = UserDefaults.standard.string(forKey: "apiURL"), !url.isEmpty {
            return url
        }
#if DEBUG
        if let envURL = ProcessInfo.processInfo.environment["API_URL"], !envURL.isEmpty {
            return envURL
        }
#endif
        return ""
    }

    public var hasCredentials: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !apiURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public init() {}

    private func loadApiKey() -> String {
        let rawKey: String?
        do {
            rawKey = try KeychainManager.read()
        } catch {
            rawKey = nil
        }
        if let key = rawKey, !key.isEmpty {
            return key
        }
#if DEBUG
        if let envKey = ProcessInfo.processInfo.environment["API_KEY"], !envKey.isEmpty {
            return envKey
        }
#endif
        return ""
    }

    public func save(apiKey: String, apiURL: String) throws {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = apiURL.trimmingCharacters(in: .whitespacesAndNewlines)

        try KeychainManager.save(key: trimmedKey)
        UserDefaults.standard.set(trimmedURL, forKey: "apiURL")

        cachedApiKey = trimmedKey
        apiKeyLoaded = true
    }
}
