//
//  APIClientTests.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import XCTest
@testable import AlokDemo

final class APIClientTests: XCTestCase {

    // Custom URLProtocol to mock responses
    class MockURLProtocol: URLProtocol {
        static var response: (data: Data?, response: URLResponse?, error: Error?)?

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let (data, response, error) = MockURLProtocol.response {
                if let error = error {
                    client?.urlProtocol(self, didFailWithError: error)
                } else {
                    if let response = response {
                        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    }
                    if let data = data {
                        client?.urlProtocol(self, didLoad: data)
                    }
                    client?.urlProtocolDidFinishLoading(self)
                }
            }
        }

        override func stopLoading() {}
    }

    private func makeAPIClient() -> APIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return APIClient(session: session)
    }

    func testFetchHoldingsSuccess() throws {
        // Given
        let apiClient = makeAPIClient()
        let holding = Holding(symbol: "AAPL", quantity: 10, avgPrice: 145.0, ltp: 150.0, close: 148.0)
        let response = HoldingsResponse(data: .init(userHolding: [holding]))
        let jsonData = try JSONEncoder().encode(response)

        let urlResponse = HTTPURLResponse(url: Endpoint.baseURL, statusCode: 200,
                                          httpVersion: nil, headerFields: nil)

        MockURLProtocol.response = (jsonData, urlResponse, nil)

        let expectation = self.expectation(description: "Fetch holdings success")

        // When
        apiClient.fetchHoldings { result in
            // Then
            switch result {
            case .success(let decoded):
                XCTAssertEqual(decoded, response)
            case .failure(let error):
                XCTFail("Expected success but got failure: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetchHoldingsFailureStatusCode() {
        // Given
        let apiClient = makeAPIClient()
        let urlResponse = HTTPURLResponse(url: Endpoint.baseURL, statusCode: 500,
                                          httpVersion: nil, headerFields: nil)

        MockURLProtocol.response = (nil, urlResponse, nil)

        let expectation = self.expectation(description: "Fetch holdings failure status code")

        // When
        apiClient.fetchHoldings { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                if case NetworkError.statusCode(500) = error {
                    XCTAssertTrue(true) // correct error
                } else {
                    XCTFail("Expected .statusCode(500) but got \(error)")
                }
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetchHoldingsDecodingError() {
        // Given
        let apiClient = makeAPIClient()
        let invalidJson = "{ invalid json }".data(using: .utf8)!

        let urlResponse = HTTPURLResponse(url: Endpoint.baseURL, statusCode: 200,
                                          httpVersion: nil, headerFields: nil)

        MockURLProtocol.response = (invalidJson, urlResponse, nil)

        let expectation = self.expectation(description: "Fetch holdings decoding error")

        // When
        apiClient.fetchHoldings { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected decoding failure but got success")
            case .failure(let error):
                if case NetworkError.decoding = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail("Expected decoding error but got \(error)")
                }
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

