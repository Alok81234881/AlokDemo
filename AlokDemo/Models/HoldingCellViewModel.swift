//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import Foundation

struct HoldingCellViewModel {
    let symbol: String
    let qtyText: String
    let avgText: String
    let ltpText: String
    let pnlText: String

    init(_ holding: Holding) {
        self.symbol = holding.symbol
        self.qtyText = String(format: "%.0f", holding.quantity)
        self.avgText = String(format: "Avg: %.2f", holding.avgPrice)
        self.ltpText = String(format: "LTP: %.2f", holding.ltp)
        let pnl = (holding.ltp - holding.avgPrice) * holding.quantity
        self.pnlText = String(format: "P&L: %.2f", pnl)
    }
}
