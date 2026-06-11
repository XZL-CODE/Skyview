//
//  CPUInfo.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation

nonisolated struct CPUInfo {
    var usage: Double           // 总使用率 0-100
    var userUsage: Double       // 用户态使用率
    var systemUsage: Double     // 系统态使用率
    var idleUsage: Double       // 空闲率
    var niceUsage: Double       // Nice 进程使用率
    var coreCount: Int          // 核心数
    var temperature: Double?    // 温度（可能无法获取）

    // Apple Silicon 特有
    var performanceCores: Int   // 性能核心数
    var efficiencyCores: Int    // 能效核心数

    // 系统负载
    var loadAverage1Min: Double
    var loadAverage5Min: Double
    var loadAverage15Min: Double

    // 处理器详情
    var brand: String           // 处理器品牌
    var architecture: String    // 架构
    var l1CacheSize: UInt64     // L1 缓存
    var l2CacheSize: UInt64     // L2 缓存
    var l3CacheSize: UInt64     // L3 缓存

    // 每核心使用率
    var perCoreUsage: [Double]

    // 格式化方法
    var l1CacheFormatted: String {
        ByteFormatter.format(l1CacheSize)
    }

    var l2CacheFormatted: String {
        ByteFormatter.format(l2CacheSize)
    }

    var l3CacheFormatted: String {
        l3CacheSize > 0 ? ByteFormatter.format(l3CacheSize) : "N/A"
    }

    var loadAverageFormatted: String {
        String(format: "%.2f / %.2f / %.2f", loadAverage1Min, loadAverage5Min, loadAverage15Min)
    }

    var isAppleSilicon: Bool {
        architecture.contains("ARM") || brand.contains("Apple")
    }

    static var placeholder: CPUInfo {
        CPUInfo(
            usage: 23.5,
            userUsage: 15.2,
            systemUsage: 8.3,
            idleUsage: 76.5,
            niceUsage: 0,
            coreCount: 10,
            temperature: nil,
            performanceCores: 6,
            efficiencyCores: 4,
            loadAverage1Min: 2.5,
            loadAverage5Min: 2.0,
            loadAverage15Min: 1.8,
            brand: "Apple M1",
            architecture: "ARM64",
            l1CacheSize: 64 * 1024,
            l2CacheSize: 4 * 1024 * 1024,
            l3CacheSize: 0,
            perCoreUsage: []
        )
    }
}
