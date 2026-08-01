import XCTest
import GrowattToolbarCore

/// Tests for `GrowattConnectionTester` using an injected
/// `URLProtocol`-backed transport, so no real network access is needed and
/// the request shape (path, auth header) can be asserted.
final class GrowattConnectionTesterTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.handler = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    private func makeResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com/status")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    // MARK: - Tests

    func testReturnsStatusOnSuccess() async throws {
        MockURLProtocol.handler = { _ in
            let body = #"{"data":{"level":65,"is_charging":true,"output_power":2500}}"#
                .data(using: .utf8)!
            return (self.makeResponse(statusCode: 200), body)
        }
        let tester = GrowattConnectionTester(session: makeSession())
        let status = try await tester.testConnection(
            apiKey: "test-key",
            apiURL: "https://example.com"
        )
        XCTAssertEqual(status.batterySoC, 65)
        XCTAssertEqual(status.state, .charging)
        XCTAssertEqual(status.outputPowerKW, 2.5)
    }

    func testRequestsStatusEndpoint() async throws {
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.url?.path, "/status")
            XCTAssertEqual(request.httpMethod, "GET")
            let body = #"{"data":{"level":65,"is_charging":true,"output_power":2500}}"#
                .data(using: .utf8)!
            return (self.makeResponse(statusCode: 200), body)
        }
        let tester = GrowattConnectionTester(session: makeSession())
        _ = try await tester.testConnection(
            apiKey: "test-key",
            apiURL: "https://example.com"
        )
    }

    func testSendsAPIKeyHeader() async throws {
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "x-api-key"), "test-key")
            let body = #"{"data":{"level":65,"is_charging":true,"output_power":2500}}"#
                .data(using: .utf8)!
            return (self.makeResponse(statusCode: 200), body)
        }
        let tester = GrowattConnectionTester(session: makeSession())
        _ = try await tester.testConnection(
            apiKey: "test-key",
            apiURL: "https://example.com"
        )
    }

    func testThrowsUnauthorizedOn401() async {
        MockURLProtocol.handler = { _ in
            (self.makeResponse(statusCode: 401), Data())
        }
        let tester = GrowattConnectionTester(session: makeSession())
        do {
            _ = try await tester.testConnection(
                apiKey: "test-key",
                apiURL: "https://example.com"
            )
            XCTFail("Expected unauthorized error")
        } catch let error as GrowattAPIError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testThrowsServerErrorOn500() async {
        MockURLProtocol.handler = { _ in
            (self.makeResponse(statusCode: 500), Data())
        }
        let tester = GrowattConnectionTester(session: makeSession())
        do {
            _ = try await tester.testConnection(
                apiKey: "test-key",
                apiURL: "https://example.com"
            )
            XCTFail("Expected server error")
        } catch let error as GrowattAPIError {
            XCTAssertEqual(error, .serverError(statusCode: 500))
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testThrowsTypedErrorForInvalidURL() async {
        let tester = GrowattConnectionTester(session: makeSession())
        do {
            _ = try await tester.testConnection(apiKey: "test-key", apiURL: "not a url")
            XCTFail("Expected a typed failure for an invalid URL")
        } catch let error as GrowattAPIError {
            guard case .networkError = error else {
                XCTFail("Unexpected error case")
                return
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testThrowsTypedErrorForEmptyURL() async {
        let tester = GrowattConnectionTester(session: makeSession())
        do {
            _ = try await tester.testConnection(apiKey: "test-key", apiURL: "")
            XCTFail("Expected a typed failure for an empty URL")
        } catch let error as GrowattAPIError {
            guard case .networkError = error else {
                XCTFail("Unexpected error case")
                return
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testThrowsTypedErrorForHostlessURL() async {
        let tester = GrowattConnectionTester(session: makeSession())
        do {
            _ = try await tester.testConnection(apiKey: "test-key", apiURL: "http://")
            XCTFail("Expected a typed failure for a hostless URL")
        } catch let error as GrowattAPIError {
            guard case .networkError = error else {
                XCTFail("Unexpected error case")
                return
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testTesterNeverPersists() async throws {
        MockURLProtocol.handler = { _ in
            let body = #"{"data":{"level":65,"is_charging":true,"output_power":2500}}"#
                .data(using: .utf8)!
            return (self.makeResponse(statusCode: 200), body)
        }
        let tester = GrowattConnectionTester(session: makeSession())
        _ = try await tester.testConnection(
            apiKey: "test-key",
            apiURL: "https://example.com"
        )
        // The tester has no persistence surface by construction; this test
        // documents the boundary — a successful test changes nothing outside
        // the returned status.
        XCTAssertEqual(
            UserDefaults.standard.string(forKey: "apiURL"),
            nil,
            "Testing must never write the draft URL to UserDefaults"
        )
    }
}

/// URLProtocol stub that replays a configured handler for every request.
final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
