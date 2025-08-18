//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import Foundation

struct PortfolioSummary: Equatable {
    let currentValue: Double
    let totalInvestment: Double
    let totalPnL: Double
    let todaysPnL: Double

    static func compute(from holdings: [Holding]) -> PortfolioSummary {
        let currentValue = holdings.reduce(0) { $0 + $1.ltp * $1.quantity }
        let totalInvestment = holdings.reduce(0) { $0 + $1.avgPrice * $1.quantity }
        let totalPnL = currentValue - totalInvestment
        let todaysPnL = holdings.reduce(0) { $0 + (($1.close - $1.ltp) * $1.quantity) }
        return PortfolioSummary(currentValue: currentValue,
                                totalInvestment: totalInvestment,
                                totalPnL: totalPnL,
                                todaysPnL: todaysPnL)
    }
}
