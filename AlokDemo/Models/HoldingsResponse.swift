//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import Foundation

struct HoldingsResponse: Codable, Hashable {
    let data: DataContainer

    struct DataContainer: Codable, Hashable {
        let userHolding: [Holding]
    }
}
