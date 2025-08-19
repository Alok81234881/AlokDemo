//
//  AlokDemoTests.swift
//  AlokDemoTests
//
//  Created by Alok SIngh on 18/08/25.
//

import XCTest
@testable import AlokDemo

final class HoldingsListViewModelTests: XCTestCase {

    // Mocking API client
    class MockAPIClient: APIClientProtocol {
        var result: Result<HoldingsResponse, Error>?
        func fetchHoldings(completion: @escaping (Result<HoldingsResponse, Error>) -> Void) {
            if let result = result {
                completion(result)
            }
        }
    }

    // Mocking Offline store
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

    class MockDelegate: HoldingsListViewModelDelegate {
        var states: [State] = []

        func holdingsListViewModel(_ viewModel: HoldingsListViewModel, didUpdateState state: State) {
            states.append(state)
        }
    }

    func testLoadSuccess() {
        
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

        
        viewModel.load {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

       
        XCTAssertEqual(viewModel.holdings, [holding])
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(delegate.states.first, .loading)
        XCTAssertEqual(delegate.states.last, .loaded)
        XCTAssertEqual(mockOffline.savedResponse, response)
    }

    func testLoadFailureWithOfflineCache() {
        
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

        
        viewModel.load {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        
        XCTAssertEqual(viewModel.holdings, [cachedHolding])
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(delegate.states.first, .loading)
        XCTAssertEqual(delegate.states.last, .loaded)
    }

    func testLoadFailureNoCache() {
        
        let mockAPI = MockAPIClient()
        let mockOffline = MockOfflineStore()
        let delegate = MockDelegate()

        mockOffline.cachedResponse = nil
        let error = NSError(domain: "APIError", code: 123)
        mockAPI.result = .failure(error)

        let viewModel = HoldingsListViewModel(api: mockAPI, offline: mockOffline)
        viewModel.delegate = delegate

        let expectation = self.expectation(description: "Load holdings failure")

        
        viewModel.load {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        
        XCTAssertTrue(viewModel.holdings.isEmpty)
        if case let .error(message) = viewModel.state {
            XCTAssertEqual(message, error.localizedDescription)
        } else {
            XCTFail("Expected state to be an error")
        }
        XCTAssertEqual(delegate.states.first, .loading)
        XCTAssertEqual(delegate.states.last, .error(error.localizedDescription))
    }
}
