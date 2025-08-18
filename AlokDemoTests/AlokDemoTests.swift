//
//  AlokDemoTests.swift
//  AlokDemoTests
//
//  Created by Alok SIngh on 18/08/25.
//

import XCTest
@testable import AlokDemo

final class HoldingsListViewModelTests: XCTestCase {

    // Mock API client
    class MockAPIClient: APIClientProtocol {
        var result: Result<HoldingsResponse, Error>?
        func fetchHoldings(completion: @escaping (Result<HoldingsResponse, Error>) -> Void) {
            if let result = result {
                completion(result)
            }
        }
    }

    // Mock Offline store
    class MockOfflineStore: OfflineHoldingsStoreProtocol {
        var savedResponse: HoldingsResponse?
        var cachedResponse: HoldingsResponse?

        func save(_ response: HoldingsResponse) throws {
            savedResponse = response
        }

        func load() -> HoldingsResponse? {
            return cachedResponse
        }
    }

    // Mock delegate to capture state updates
    class MockDelegate: HoldingsListViewModelDelegate {
        var states: [State] = []

        func holdingsListViewModel(_ viewModel: HoldingsListViewModel, didUpdateState state: State) {
            states.append(state)
        }
    }

    func testLoadSuccess() {
        // Given
        let mockAPI = MockAPIClient()
        let mockOffline = MockOfflineStore()
        let delegate = MockDelegate()

        let holding = Holding(
            symbol: "AAPL",
            quantity: 10,
            avgPrice: 145.0,
            ltp: 150.0,
            close: 148.0
        )
        let response = HoldingsResponse(data: .init(userHolding: [holding]))
        mockAPI.result = .success(response)

        let viewModel = HoldingsListViewModel(api: mockAPI, offline: mockOffline)
        viewModel.delegate = delegate

        let expectation = self.expectation(description: "Load holdings success")

        // When
        viewModel.load {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        XCTAssertEqual(viewModel.holdings, [holding])
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(delegate.states.first, .loading)
        XCTAssertEqual(delegate.states.last, .loaded)
        XCTAssertEqual(mockOffline.savedResponse, response)
    }

    func testLoadFailureWithOfflineCache() {
        // Given
        let mockAPI = MockAPIClient()
        let mockOffline = MockOfflineStore()
        let delegate = MockDelegate()

        let cachedHolding = Holding(
            symbol: "GOOGL",
            quantity: 5,
            avgPrice: 2750.0,
            ltp: 2800.0,
            close: 2785.0
        )
        let cachedResponse = HoldingsResponse(data: .init(userHolding: [cachedHolding]))
        mockOffline.cachedResponse = cachedResponse

        mockAPI.result = .failure(NSError(domain: "APIError", code: 0))

        let viewModel = HoldingsListViewModel(api: mockAPI, offline: mockOffline)
        viewModel.delegate = delegate

        let expectation = self.expectation(description: "Load holdings with offline fallback")

        // When
        viewModel.load {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        XCTAssertEqual(viewModel.holdings, [cachedHolding])
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(delegate.states.first, .loading)
        XCTAssertEqual(delegate.states.last, .loaded)
    }

    func testLoadFailureNoCache() {
        // Given
        let mockAPI = MockAPIClient()
        let mockOffline = MockOfflineStore()
        let delegate = MockDelegate()

        mockOffline.cachedResponse = nil
        let error = NSError(domain: "APIError", code: 123)
        mockAPI.result = .failure(error)

        let viewModel = HoldingsListViewModel(api: mockAPI, offline: mockOffline)
        viewModel.delegate = delegate

        let expectation = self.expectation(description: "Load holdings failure")

        // When
        viewModel.load {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        XCTAssertTrue(viewModel.holdings.isEmpty)
        if case let .error(message) = viewModel.state {
            XCTAssertEqual(message, error.localizedDescription)
        } else {
            XCTFail("Expected state to be .error")
        }
        XCTAssertEqual(delegate.states.first, .loading)
        XCTAssertEqual(delegate.states.last, .error(error.localizedDescription))
    }
}
