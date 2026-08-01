import Foundation
import XCTest
import GrowattToolbarCore

/// State-machine tests for `SettingsViewModel`: local validation, tested-value
/// invalidation, loading and duplicate-operation prevention, safe error
/// mapping, and persistence boundaries.
@MainActor
final class SettingsViewModelTests: XCTestCase {
    private var tester: MockConnectionTester!
    private var persistedKey: String?
    private var persistedURL: String?
    private var persistShouldFail = false
    private var completedSaves: [(String, String)] = []

    override func setUp() {
        super.setUp()
        tester = MockConnectionTester()
        persistedKey = nil
        persistedURL = nil
        persistShouldFail = false
        completedSaves = []
    }

    // MARK: - Helpers

    private func makeViewModel(apiKey: String = "", apiURL: String = "") -> SettingsViewModel {
        let viewModel = SettingsViewModel(apiKey: apiKey, apiURL: apiURL, tester: tester) { [weak self] key, url in
            guard let self else { return }
            if self.persistShouldFail {
                throw GrowattAPIError.keychainError("Simulated persistence failure")
            }
            self.persistedKey = key
            self.persistedURL = url
        }
        viewModel.onSaveCompleted = { [weak self] key, url in
            self?.completedSaves.append((key, url))
        }
        return viewModel
    }

    // MARK: - Local validation

    func testEmptyKeyIsInvalid() {
        let viewModel = makeViewModel(apiKey: "", apiURL: "https://example.com")
        XCTAssertFalse(viewModel.isDraftValid)
        XCTAssertFalse(viewModel.canTest)
        XCTAssertFalse(viewModel.canSave)
    }

    func testWhitespaceOnlyKeyIsInvalid() {
        let viewModel = makeViewModel(apiKey: "   ", apiURL: "https://example.com")
        XCTAssertFalse(viewModel.isDraftValid)
        XCTAssertFalse(viewModel.canTest)
    }

    func testNonHTTPSSchemeIsInvalid() {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "ftp://example.com")
        XCTAssertFalse(viewModel.isDraftValid)
        XCTAssertEqual(viewModel.urlValidationMessage, "The API URL must use http or https.")
        XCTAssertFalse(viewModel.canTest)
    }

    func testMissingHostIsInvalid() {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "http://")
        XCTAssertFalse(viewModel.isDraftValid)
        XCTAssertNotNil(viewModel.urlValidationMessage)
        XCTAssertFalse(viewModel.canTest)
    }

    func testUnparseableURLIsInvalid() {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "not a url")
        XCTAssertFalse(viewModel.isDraftValid)
        XCTAssertNotNil(viewModel.urlValidationMessage)
    }

    func testValidDraftIsValid() {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://192.168.1.5")
        XCTAssertTrue(viewModel.isDraftValid)
        XCTAssertNil(viewModel.urlValidationMessage)
        XCTAssertTrue(viewModel.canTest)
    }

    func testEmptyURLShowsNoValidationFeedback() {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "")
        XCTAssertNil(viewModel.urlValidationMessage)
        XCTAssertFalse(viewModel.canTest)
    }

    // MARK: - Connection testing

    func testTestConnectionUsesExactNormalizedDraftValues() async {
        let viewModel = makeViewModel(apiKey: "  key-123  ", apiURL: " https://example.com ")
        await viewModel.testConnection()
        XCTAssertEqual(tester.requestedKeys, ["key-123"])
        XCTAssertEqual(tester.requestedURLs, ["https://example.com"])
        XCTAssertEqual(tester.callCount, 1)
    }

    func testTestConnectionNeverPersists() async {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        await viewModel.testConnection()
        XCTAssertNil(persistedKey)
        XCTAssertNil(persistedURL)
        XCTAssertTrue(completedSaves.isEmpty)
    }

    func testSuccessfulTestEnablesSave() async {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        XCTAssertFalse(viewModel.canSave)
        await viewModel.testConnection()
        XCTAssertEqual(viewModel.testStatus, .success)
        XCTAssertTrue(viewModel.isTestValid)
        XCTAssertTrue(viewModel.canSave)
        XCTAssertFalse(viewModel.isTesting)
    }

    func testEditKeyAfterTestInvalidates() async {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        await viewModel.testConnection()
        viewModel.apiKey = "different-key"
        XCTAssertEqual(viewModel.testStatus, .idle)
        XCTAssertFalse(viewModel.isTestValid)
        XCTAssertFalse(viewModel.canSave)
    }

    func testEditURLAfterTestInvalidates() async {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        await viewModel.testConnection()
        viewModel.apiURL = "https://other.example.com"
        XCTAssertEqual(viewModel.testStatus, .idle)
        XCTAssertFalse(viewModel.canSave)
    }

    func testWhitespaceOnlyEditKeepsTestValid() async {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        await viewModel.testConnection()
        viewModel.apiURL = " https://example.com "
        viewModel.apiKey = " key-123 "
        XCTAssertEqual(viewModel.testStatus, .success)
        XCTAssertTrue(viewModel.isTestValid)
        XCTAssertTrue(viewModel.canSave)
    }

    func testEditDuringTestIgnoresStaleResult() async {
        let gate = GateConnectionTester()
        let viewModel = SettingsViewModel(
            apiKey: "key-123",
            apiURL: "https://example.com",
            tester: gate
        ) { _, _ in }
        let task = Task { await viewModel.testConnection() }
        await waitUntil { gate.isSuspended }
        viewModel.apiKey = "edited-while-testing"
        gate.resume()
        await task.value
        XCTAssertEqual(viewModel.testStatus, .idle)
        XCTAssertFalse(viewModel.isTestValid)
        XCTAssertFalse(viewModel.canSave)
        XCTAssertFalse(viewModel.isTesting)
    }

    // MARK: - Loading state and duplicate prevention

    func testLoadingPreventsDuplicateTestAndSave() async {
        let gate = GateConnectionTester()
        let viewModel = SettingsViewModel(
            apiKey: "key-123",
            apiURL: "https://example.com",
            tester: gate
        ) { _, _ in }
        let task = Task { await viewModel.testConnection() }
        await waitUntil { gate.isSuspended }

        XCTAssertTrue(viewModel.isTesting)
        XCTAssertFalse(viewModel.canTest)
        XCTAssertFalse(viewModel.canSave)

        let callsBefore = gate.callCount
        await viewModel.testConnection()
        XCTAssertEqual(gate.callCount, callsBefore)

        viewModel.save()
        XCTAssertNil(persistedKey)

        gate.resume()
        await task.value
        XCTAssertEqual(viewModel.testStatus, .success)
        XCTAssertFalse(viewModel.isTesting)
        XCTAssertTrue(viewModel.canSave)
    }

    // MARK: - Safe error mapping

    func testUnauthorizedMapsToSafeMessage() async {
        tester.result = .failure(.unauthorized)
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        await viewModel.testConnection()
        XCTAssertEqual(
            viewModel.testStatus,
            .failure("The API key was rejected. Check the key and try again.")
        )
        XCTAssertFalse(viewModel.isTestValid)
        XCTAssertFalse(viewModel.canSave)
        XCTAssertEqual(viewModel.apiKey, "key-123")
    }

    func testNetworkErrorMapsToSafeMessage() async {
        tester.result = .failure(.networkError("underlying technical detail"))
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        await viewModel.testConnection()
        XCTAssertEqual(
            viewModel.testStatus,
            .failure("The API could not be reached. Check the URL and network connection.")
        )
    }

    func testDecodingErrorMapsToSafeMessage() async {
        tester.result = .failure(.decodingError("underlying parse failure"))
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        await viewModel.testConnection()
        XCTAssertEqual(
            viewModel.testStatus,
            .failure("The endpoint returned an unexpected response.")
        )
    }

    func testServerErrorMapsToSafeMessage() async {
        tester.result = .failure(.serverError(statusCode: 503))
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        await viewModel.testConnection()
        XCTAssertEqual(
            viewModel.testStatus,
            .failure("The API server is unavailable right now. Try again later.")
        )
    }

    func testSafeMessagesNeverLeakTechnicalDetails() {
        let statusCodeMessage = GrowattAPIError.serverError(statusCode: 503).safeUserMessage
        XCTAssertFalse(statusCodeMessage.contains("503"))
        XCTAssertFalse(statusCodeMessage.contains("server responded"))

        let networkMessage = GrowattAPIError.networkError("host unreachable in /var/log").safeUserMessage
        XCTAssertFalse(networkMessage.contains("host"))
        XCTAssertFalse(networkMessage.contains("/var/log"))

        let keychainMessage = GrowattAPIError.keychainError("OSStatus -25293").safeUserMessage
        XCTAssertFalse(keychainMessage.contains("25293"))
        XCTAssertEqual(
            keychainMessage,
            "The credentials could not be saved securely. Try again."
        )
    }

    // MARK: - Persistence boundaries

    func testSaveNotAllowedBeforeTest() {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        XCTAssertFalse(viewModel.canSave)
        viewModel.save()
        XCTAssertNil(persistedKey)
        XCTAssertNil(persistedURL)
        XCTAssertTrue(completedSaves.isEmpty)
    }

    func testSavePersistsNormalizedValuesAndCompletes() async {
        let viewModel = makeViewModel(apiKey: "  key-123  ", apiURL: " https://example.com ")
        await viewModel.testConnection()
        viewModel.save()
        XCTAssertEqual(persistedKey, "key-123")
        XCTAssertEqual(persistedURL, "https://example.com")
        XCTAssertEqual(completedSaves.count, 1)
        XCTAssertFalse(viewModel.isSaving)
    }

    func testSaveFailurePreservesDraftAndDoesNotComplete() async {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        await viewModel.testConnection()
        persistShouldFail = true
        viewModel.save()
        XCTAssertEqual(
            viewModel.saveError,
            "The credentials could not be saved securely. Try again."
        )
        XCTAssertTrue(completedSaves.isEmpty)
        XCTAssertEqual(viewModel.apiKey, "key-123")
        XCTAssertEqual(viewModel.apiURL, "https://example.com")
        XCTAssertFalse(viewModel.isSaving)
    }

    func testSaveAfterTestRemainsAvailableAfterFailure() async {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        await viewModel.testConnection()
        persistShouldFail = true
        viewModel.save()
        XCTAssertNotNil(viewModel.saveError)
        persistShouldFail = false
        XCTAssertTrue(viewModel.canSave)
        viewModel.save()
        XCTAssertEqual(completedSaves.count, 1)
    }

    // MARK: - Unsaved edits

    func testHasUnsavedEditsReflectsDraftDelta() {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        XCTAssertFalse(viewModel.hasUnsavedEdits)
        viewModel.apiKey = "key-456"
        XCTAssertTrue(viewModel.hasUnsavedEdits)
        viewModel.apiKey = "key-123"
        XCTAssertFalse(viewModel.hasUnsavedEdits)
    }

    func testWhitespaceOnlyDraftIsNotUnsavedEdit() {
        let viewModel = makeViewModel(apiKey: "key-123", apiURL: "https://example.com")
        viewModel.apiKey = "  key-123  "
        XCTAssertFalse(viewModel.hasUnsavedEdits)
    }

    // MARK: - Wait helper

    private func waitUntil(_ condition: () -> Bool, timeout: TimeInterval = 2) async {
        let start = Date()
        while !condition(), Date().timeIntervalSince(start) < timeout {
            await Task.yield()
        }
    }
}

/// Test double that suspends on the first call until `resume()` is invoked,
/// letting tests observe the in-flight loading state deterministically.
private final class GateConnectionTester: GrowattConnectionTesterProtocol, @unchecked Sendable {
    private var continuation: CheckedContinuation<Void, Never>?
    private(set) var isSuspended = false
    private(set) var callCount = 0

    func testConnection(apiKey: String, apiURL: String) async throws -> InverterStatus {
        callCount += 1
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.continuation = continuation
            self.isSuspended = true
        }
        return InverterStatus(batterySoC: 50, state: .charging, outputPowerKW: 1.2)
    }

    func resume() {
        continuation?.resume()
        continuation = nil
        isSuspended = false
    }
}
