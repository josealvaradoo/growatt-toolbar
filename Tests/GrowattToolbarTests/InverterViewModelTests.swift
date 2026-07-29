import XCTest
import Foundation
@testable import GrowattToolbarCore

@MainActor
final class InverterViewModelTests: XCTestCase {

    func testViewModelInitialization() {
        let viewModel = InverterViewModel()

        XCTAssertEqual(viewModel.status.batterySoC, 85)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testViewModelRefresh() async {
        let mockService = MockGrowattAPIService()
        let viewModel = InverterViewModel(service: mockService)

        await viewModel.refreshData()

        XCTAssertEqual(viewModel.status.batterySoC, 85)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testViewModelErrorState() async {
        let mockService = MockGrowattAPIService(shouldThrowError: true)
        let viewModel = InverterViewModel(service: mockService)

        await viewModel.refreshData()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}
