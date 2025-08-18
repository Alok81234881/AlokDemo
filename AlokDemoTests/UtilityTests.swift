//
//  UtilityTests.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import XCTest
@testable import AlokDemo

final class UtilityTests: XCTestCase {

    func testCurrencyFormatterMoney() {
        // Positive value
        let value1 = 1234.56
        let formatted1 = CurrencyFormatter.money(value1)
        XCTAssertTrue(formatted1.contains("₹") || formatted1.contains("INR"), "Should include currency symbol")
        XCTAssertTrue(formatted1.contains("1,234.56") || formatted1.contains("1234.56"))

        // Zero value
        let value2 = 0.0
        let formatted2 = CurrencyFormatter.money(value2)
        XCTAssertTrue(formatted2.contains("0") || formatted2.contains("₹"))

        // Negative value
        let value3 = -9876.54
        let formatted3 = CurrencyFormatter.money(value3)
        XCTAssertTrue(formatted3.contains("-") || formatted3.contains("₹"))
    }

    func testAsRupeeWithoutSign() {
        let value: Double = 1500.75
        let formatted = value.asRupee()
        XCTAssertTrue(formatted.contains("₹"))
        XCTAssertTrue(formatted.contains("1,500.75"))
        XCTAssertFalse(formatted.contains("-"))
    }

    func testAsRupeeWithSignPositive() {
        let value: Double = 1234.56
        let formatted = value.asRupee(sign: true)
        XCTAssertEqual(formatted, "₹1,234.56")
    }

    func testAsRupeeWithSignNegative() {
        let value: Double = -1234.56
        let formatted = value.asRupee(sign: true)
        XCTAssertEqual(formatted, "-₹1,234.56")
    }

    func testAsRupeeWithPercent() {
        let value: Double = 500
        let formatted = value.asRupee(showPercent: true, percent: 0.1234)
        XCTAssertEqual(formatted, "₹500.00 (12.34%)")
    }

    func testAsRupeeWithSignAndPercentNegative() {
        let value: Double = -750
        let formatted = value.asRupee(sign: true, showPercent: true, percent: 0.25)
        XCTAssertEqual(formatted, "-₹750.00 (25.00%)")
    }

    func testAsRupeeZeroValue() {
        let value: Double = 0
        let formatted = value.asRupee()
        XCTAssertEqual(formatted, "₹0.00")
    }
}
