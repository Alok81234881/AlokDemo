//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import Foundation

protocol OfflineHoldingsStoreProtocol {
    func save(_ response: HoldingsResponse) throws
    func load() -> HoldingsResponse?
}

final class OfflineHoldingsStore: OfflineHoldingsStoreProtocol {
    private let cache: CacheStoreProtocol
    private let key = "holdings_response"

    init(cache: CacheStoreProtocol = CacheStore()) {
        self.cache = cache
    }

    func save(_ response: HoldingsResponse) throws {
        let data = try JSONEncoder().encode(response)
        try cache.save(data: data, forKey: key)
    }

    func load() -> HoldingsResponse? {
        guard let data = cache.load(forKey: key) else { return nil }
        return try? JSONDecoder().decode(HoldingsResponse.self, from: data)
    }
}
