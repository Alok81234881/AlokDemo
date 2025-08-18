//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import Foundation

protocol CacheStoreProtocol {
    func save(data: Data, forKey key: String) throws
    func load(forKey key: String) -> Data?
}

final class CacheStore: CacheStoreProtocol {
    private let directory: URL

    init(directory: URL? = nil) {
        if let directory = directory {
            self.directory = directory
        } else {
            self.directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("HoldingsCache", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    func save(data: Data, forKey key: String) throws {
        let url = directory.appendingPathComponent(key + ".json")
        try data.write(to: url, options: [.atomic])
    }

    func load(forKey key: String) -> Data? {
        let url = directory.appendingPathComponent(key + ".json")
        return try? Data(contentsOf: url)
    }
}
