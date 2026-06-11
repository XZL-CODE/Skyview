//
//  ByteFormatterTests.swift
//  SkyviewTests
//
//  Created by xzl on 2026/6/10.
//

import XCTest
@testable import Skyview

final class ByteFormatterTests: XCTestCase {

    func testBytesUnderOneKB() {
        XCTAssertEqual(ByteFormatter.format(UInt64(0)), "0 B")
        XCTAssertEqual(ByteFormatter.format(UInt64(512)), "512 B")
        XCTAssertEqual(ByteFormatter.format(UInt64(1023)), "1023 B")
    }

    func testUnitBoundaries() {
        XCTAssertEqual(ByteFormatter.format(UInt64(1024)), "1.0 KB")
        XCTAssertEqual(ByteFormatter.format(UInt64(1024 * 1024)), "1.0 MB")
        XCTAssertEqual(ByteFormatter.format(UInt64(1024 * 1024 * 1024)), "1.0 GB")
        XCTAssertEqual(ByteFormatter.format(UInt64(1024) * 1024 * 1024 * 1024), "1.0 TB")
    }

    func testDecimals() {
        XCTAssertEqual(ByteFormatter.format(UInt64(1536)), "1.5 KB")
        XCTAssertEqual(ByteFormatter.format(UInt64(1536), decimals: 2), "1.50 KB")
    }

    func testNegativeInt64ClampsToZero() {
        XCTAssertEqual(ByteFormatter.format(Int64(-100)), "0 B")
    }

    func testSpeedFormatting() {
        XCTAssertEqual(ByteFormatter.formatSpeed(0), "0 B/s")
        XCTAssertEqual(ByteFormatter.formatSpeed(2048), "2.0 KB/s")
        XCTAssertEqual(ByteFormatter.formatSpeed(3.5 * 1024 * 1024), "3.5 MB/s")
    }

    func testPercentage() {
        XCTAssertEqual(ByteFormatter.formatPercentage(46.13), "46.1%")
    }
}
