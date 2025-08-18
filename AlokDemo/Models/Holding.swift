//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import Foundation

struct Holding: Codable, Hashable {
    let symbol: String
    let quantity: Double
    let avgPrice: Double
    let ltp: Double
    let close: Double
}
enum State: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}
