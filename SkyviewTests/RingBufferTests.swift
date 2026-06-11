//
//  RingBufferTests.swift
//  SkyviewTests
//
//  Created by xzl on 2026/6/10.
//

import XCTest
@testable import Skyview

final class RingBufferTests: XCTestCase {

    func testEmptyBuffer() {
        let buffer = RingBuffer(capacity: 5, defaultValue: 0.0)
        XCTAssertEqual(buffer.count, 0)
        XCTAssertTrue(buffer.toArray().isEmpty)
    }

    func testPartialFill() {
        var buffer = RingBuffer(capacity: 5, defaultValue: 0.0)
        buffer.append(1.0)
        buffer.append(2.0)
        buffer.append(3.0)

        XCTAssertEqual(buffer.count, 3)
        XCTAssertEqual(buffer.toArray(), [1.0, 2.0, 3.0])
    }

    func testExactFill() {
        var buffer = RingBuffer(capacity: 3, defaultValue: 0.0)
        buffer.append(1.0)
        buffer.append(2.0)
        buffer.append(3.0)

        XCTAssertEqual(buffer.count, 3)
        XCTAssertEqual(buffer.toArray(), [1.0, 2.0, 3.0])
    }

    func testWrapAroundKeepsChronologicalOrder() {
        var buffer = RingBuffer(capacity: 3, defaultValue: 0.0)
        for value in [1.0, 2.0, 3.0, 4.0, 5.0] {
            buffer.append(value)
        }

        // 容量 3, 写入 5 个 → 只保留最近 3 个, 且按时间顺序输出
        XCTAssertEqual(buffer.count, 3)
        XCTAssertEqual(buffer.toArray(), [3.0, 4.0, 5.0])
    }

    func testCountNeverExceedsCapacity() {
        var buffer = RingBuffer(capacity: 2, defaultValue: 0)
        for value in 1...100 {
            buffer.append(value)
        }
        XCTAssertEqual(buffer.count, 2)
        XCTAssertEqual(buffer.toArray(), [99, 100])
    }
}
