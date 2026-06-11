//
//  ModelMathTests.swift
//  SkyviewTests
//
//  Created by xzl on 2026/6/10.
//

import XCTest
@testable import Skyview

final class ModelMathTests: XCTestCase {

    func testMemoryUsagePercentage() {
        var info = MemoryInfo.placeholder
        info.total = 32 * 1024 * 1024 * 1024
        info.used = 16 * 1024 * 1024 * 1024
        XCTAssertEqual(info.usagePercentage, 50.0, accuracy: 0.001)
    }

    func testMemoryUsagePercentageZeroTotal() {
        var info = MemoryInfo.placeholder
        info.total = 0
        info.used = 100
        XCTAssertEqual(info.usagePercentage, 0)
    }

    func testStorageUsagePercentage() {
        var info = StorageInfo.placeholder
        info.total = 1000
        info.used = 461
        XCTAssertEqual(info.usagePercentage, 46.1, accuracy: 0.001)
    }

    func testCPUIsAppleSilicon() {
        var info = CPUInfo.placeholder
        info.brand = "Apple M1 Pro"
        info.architecture = "ARM64 (Apple Silicon)"
        XCTAssertTrue(info.isAppleSilicon)

        info.brand = "Intel(R) Core(TM) i7"
        info.architecture = "x86_64 (Intel)"
        XCTAssertFalse(info.isAppleSilicon)
    }

    func testLiveMemoryMonitorInvariants() {
        // 真实采集一次, 验证活动监视器口径的基本不变量
        let info = MemoryMonitor().getMemoryInfo()

        XCTAssertGreaterThan(info.total, 0)
        XCTAssertGreaterThan(info.used, 0)
        XCTAssertLessThanOrEqual(info.used, info.total, "已使用不应超过总内存")
        XCTAssertEqual(info.used + info.free, info.total, "已使用 + 可用 应等于总量")
        XCTAssertTrue((0...100).contains(info.usagePercentage))
    }

    func testLiveCPUMonitorInvariants() {
        let monitor = CPUMonitor()
        _ = monitor.getCPUInfo()
        // 第二次采样才有差值, 各分量应在合法区间
        let info = monitor.getCPUInfo()

        XCTAssertGreaterThanOrEqual(info.usage, 0)
        XCTAssertLessThanOrEqual(info.usage, 100.001)
        XCTAssertGreaterThan(info.coreCount, 0)
        XCTAssertFalse(info.brand.isEmpty)
    }
}
