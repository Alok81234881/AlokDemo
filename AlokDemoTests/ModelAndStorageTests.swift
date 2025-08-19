//
//  ModelAndStorageTests.swift
//  AlokDemoTests
//
//  Created by Assistant on 19/08/25.
//

import XCTest
@testable import AlokDemo

final class ModelAndStorageTests: XCTestCase {
    
    func testSaveAndLoadHoldingsResponse() throws {
        // Mock cache store
        class MockCache: CacheStoreProtocol {
            var store = [String: Data]()
            func save(data: Data, forKey key: String) throws { store[key] = data }
            func load(forKey key: String) -> Data? { store[key] }
        }
        let mockCache = MockCache()
        let storage = OfflineHoldingsStore(cache: mockCache)
        let holding = Holding(symbol: "AAPL", quantity: 5, avgPrice: 100, ltp: 110, close: 105)
        let response = HoldingsResponse(data: .init(userHolding: [holding]))
        try storage.save(response)
        let loaded = storage.load()
        XCTAssertEqual(loaded, response)
    }
    
    func testLoadReturnsNilIfNoData() throws {
        class MockCache: CacheStoreProtocol {
            func save(data: Data, forKey key: String) throws {}
            func load(forKey key: String) -> Data? { nil }
        }
        let mockCache = MockCache()
        let storage = OfflineHoldingsStore(cache: mockCache)
        let loaded = storage.load()
        XCTAssertNil(loaded)
    }
    
    func testSaveOverwritesPreviousData() throws {
        class MockCache: CacheStoreProtocol {
            var store = [String: Data]()
            func save(data: Data, forKey key: String) throws { store[key] = data }
            func load(forKey key: String) -> Data? { store[key] }
        }
        let mockCache = MockCache()
        let storage = OfflineHoldingsStore(cache: mockCache)
        let holding1 = Holding(symbol: "AAPL", quantity: 1, avgPrice: 10, ltp: 11, close: 10.5)
        let holding2 = Holding(symbol: "GOOG", quantity: 2, avgPrice: 20, ltp: 21, close: 20.5)
        let response1 = HoldingsResponse(data: .init(userHolding: [holding1]))
        let response2 = HoldingsResponse(data: .init(userHolding: [holding2]))
        try storage.save(response1)
        try storage.save(response2)
        let loaded = storage.load()
        XCTAssertEqual(loaded, response2)
    }
    
    func testLoadReturnsDecodedDataForMultipleHoldings() throws {
        class MockCache: CacheStoreProtocol {
            var store = [String: Data]()
            func save(data: Data, forKey key: String) throws { store[key] = data }
            func load(forKey key: String) -> Data? { store[key] }
        }
        let mockCache = MockCache()
        let storage = OfflineHoldingsStore(cache: mockCache)
        let holding1 = Holding(symbol: "AAPL", quantity: 1, avgPrice: 10, ltp: 11, close: 10.5)
        let holding2 = Holding(symbol: "GOOG", quantity: 2, avgPrice: 20, ltp: 21, close: 20.5)
        let response = HoldingsResponse(data: .init(userHolding: [holding1, holding2]))
        try storage.save(response)
        let loaded = storage.load()
        XCTAssertEqual(loaded, response)
    }
}
