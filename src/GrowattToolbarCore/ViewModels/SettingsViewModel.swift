import Foundation
import Observation

/// Owns the settings/onboarding state machine: draft credentials, local
/// validation, connection testing, and save/update orchestration.
///
/// The tested state is tied to the exact current normalized draft values:
/// changing either field after a successful test invalidates it, and a test
/// result is only applied when the draft still matches the values it tested.
/// Test Connection never persists anything; Save/Update is the only path
/// that calls the injected persistence closure.
@Observable
@MainActor
public final class SettingsViewModel {
    public var apiKey: String {
        didSet { invalidateTest() }
    }

    public var apiURL: String {
        didSet { invalidateTest() }
    }

    public private(set) var isTesting: Bool = false
    public private(set) var isSaving: Bool = false
    public private(set) var testStatus: ConnectionTestStatus = .idle
    public private(set) var saveError: String?

    /// Invoked after persistence succeeds, with the exact persisted values.
    /// The AppKit layer uses this to reconfigure the runtime service, mark
    /// onboarding complete, and dismiss the window.
    public var onSaveCompleted: (@MainActor (String, String) -> Void)?

    private let tester: GrowattConnectionTesterProtocol
    private let persist: @MainActor (String, String) throws -> Void
    private let initialKey: String
    private let initialURL: String
    private var testedKey: String?
    private var testedURL: String?

    public init(
        apiKey: String = "",
        apiURL: String = "",
        tester: GrowattConnectionTesterProtocol,
        persist: @escaping @MainActor (String, String) throws -> Void
    ) {
        self.apiKey = apiKey
        self.apiURL = apiURL
        self.initialKey = apiKey
        self.initialURL = apiURL
        self.tester = tester
        self.persist = persist
    }

    // MARK: - Draft state

    /// True when the trimmed API key is non-empty and the trimmed URL is an
    /// `http`/`https` URL with a non-empty host.
    public var isDraftValid: Bool {
        guard !normalizedKey.isEmpty else { return false }
        guard let url = URL(string: normalizedURL) else { return false }
        guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            return false
        }
        guard let host = url.host, !host.isEmpty else { return false }
        return true
    }

    /// User-facing feedback for the URL field. `nil` when the field is empty
    /// or valid, so the form only surfaces guidance once the user has typed.
    public var urlValidationMessage: String? {
        let trimmed = normalizedURL
        guard !trimmed.isEmpty else { return nil }
        guard let url = URL(string: trimmed) else {
            return "Enter a valid URL beginning with http:// or https://."
        }
        guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            return "The API URL must use http or https."
        }
        guard let host = url.host, !host.isEmpty else {
            return "The API URL must include a host, such as http://192.168.1.5."
        }
        return nil
    }

    /// True when the draft differs from the values the window was opened
    /// with. Used to confirm before discarding unsaved edits.
    public var hasUnsavedEdits: Bool {
        let trimmedInitialKey = initialKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInitialURL = initialURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalizedKey != trimmedInitialKey || normalizedURL != trimmedInitialURL
    }

    // MARK: - Test state

    /// True when the latest successful test ran against the exact current
    /// normalized draft values.
    public var isTestValid: Bool {
        guard testStatus == .success, let testedKey, let testedURL else { return false }
        return testedKey == normalizedKey && testedURL == normalizedURL
    }

    /// Test Connection is available only when the draft is locally valid and
    /// no operation is in flight.
    public var canTest: Bool {
        isDraftValid && !isTesting && !isSaving
    }

    /// Save/Update is available only when local validation passes, the latest
    /// test succeeded against the current values, and no operation is active.
    public var canSave: Bool {
        isDraftValid && isTestValid && !isTesting && !isSaving
    }

    /// Runs a connection test with the current draft values using a temporary
    /// service. Never persists anything. Ignores stale results when the draft
    /// changes while the request is in flight.
    public func testConnection() async {
        guard canTest else { return }
        let key = normalizedKey
        let url = normalizedURL
        isTesting = true
        testStatus = .testing
        saveError = nil

        let outcome: ConnectionTestStatus
        do {
            _ = try await tester.testConnection(apiKey: key, apiURL: url)
            outcome = .success
        } catch let error as GrowattAPIError {
            outcome = .failure(error.safeUserMessage)
        } catch {
            outcome = .failure(GrowattAPIError.networkError("Unknown connection failure").safeUserMessage)
        }

        guard key == normalizedKey, url == normalizedURL else {
            testStatus = .idle
            testedKey = nil
            testedURL = nil
            isTesting = false
            return
        }
        if outcome == .success {
            testedKey = key
            testedURL = url
        }
        testStatus = outcome
        isTesting = false
    }

    // MARK: - Persistence

    /// Persists the current draft. Only reachable when `canSave`; failures
    /// preserve the draft and surface a safe message without invoking
    /// `onSaveCompleted`.
    public func save() {
        guard canSave else { return }
        isSaving = true
        saveError = nil
        let key = normalizedKey
        let url = normalizedURL
        do {
            try persist(key, url)
            onSaveCompleted?(key, url)
        } catch let error as GrowattAPIError {
            saveError = error.safeUserMessage
        } catch {
            saveError = GrowattAPIError.keychainError("Unknown persistence failure").safeUserMessage
        }
        isSaving = false
    }

    // MARK: - Helpers

    private var normalizedKey: String {
        apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedURL: String {
        apiURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func invalidateTest() {
        if (testedKey == normalizedKey) && (testedURL == normalizedURL) {
            // Whitespace-only edits keep the tested values intact: the test
            // state is tied to normalized values, not raw keystrokes.
            return
        }
        if testStatus != .testing {
            testStatus = .idle
        }
        testedKey = nil
        testedURL = nil
        saveError = nil
    }
}
