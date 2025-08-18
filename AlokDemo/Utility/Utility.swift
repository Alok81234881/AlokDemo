//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import Foundation

enum CurrencyFormatter {
    static func money(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "INR"
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - Helpers
extension Double {
    func asRupee(sign: Bool = false, showPercent: Bool = false, percent: Double? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        let absVal = abs(self)
        let formatted = formatter.string(from: NSNumber(value: absVal)) ?? String(format: "%.2f", absVal)
        let s = sign ? (self >= 0 ? "" : "-") : ""
        if showPercent, let percent = percent {
            return "\(s)\(formatted) (\(String(format: "%.2f", percent * 100))%)"
        } else {
            return "\(s)\(formatted)"
        }
    }
}

