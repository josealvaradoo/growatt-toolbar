import XCTest
import Foundation
@testable import GrowattToolbarCore

final class GrowattAPIServiceTests: XCTestCase {

    func testMockServiceSuccess() async throws {
        let mock = MockGrowattAPIService()
        let result = try await mock.fetchInverterStatus()

        XCTAssertEqual(result.batterySoC, 85)
        XCTAssertEqual(result.state, .charging)
        XCTAssertEqual(result.batteryPowerKW, 3.2)
    }

    func testMockServiceError() async {
        let mock = MockGrowattAPIService(shouldThrowError: true)
        
        do {
            _ = try await mock.fetchInverterStatus()
            XCTFail("Expected error but fetch succeeded")
        } catch {
            XCTAssertTrue(error is GrowattAPIError)
        }
    }

    func testMockServiceStateToggle() async throws {
        let mock = MockGrowattAPIService()
        XCTAssertEqual(mock.mockStatus.state, .charging)

        mock.toggleState()
        XCTAssertEqual(mock.mockStatus.state, .discharging)
        XCTAssertTrue(mock.mockStatus.batteryPowerKW < 0)

        mock.toggleState()
        XCTAssertEqual(mock.mockStatus.state, .charging)
        XCTAssertTrue(mock.mockStatus.batteryPowerKW > 0)
    }
}
