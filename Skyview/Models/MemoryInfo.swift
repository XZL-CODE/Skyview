//
//  MemoryInfo.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation

nonisolated struct MemoryInfo {
    var total: UInt64           // 总内存
    var used: UInt64            // 已使用
    var free: UInt64            // 空闲
    var active: UInt64          // 活跃
    var inactive: UInt64        // 非活跃
    var wired: UInt64           // 已联动
    var compressed: UInt64      // 已压缩
    var appMemory: UInt64       // 应用内存

    var usagePercentage: Double {
        guard total > 0 else { return 0 }
        return Double(used) / Double(total) * 100
    }

    static var placeholder: MemoryInfo {
        let total: UInt64 = 16 * 1024 * 1024 * 1024
        let used: UInt64 = 12 * 1024 * 1024 * 1024
        return MemoryInfo(
            total: total,
            used: used,
            free: total - used,
            active: 6 * 1024 * 1024 * 1024,
            inactive: 3 * 1024 * 1024 * 1024,
            wired: 2 * 1024 * 1024 * 1024,
            compressed: 1 * 1024 * 1024 * 1024,
            appMemory: 8 * 1024 * 1024 * 1024
        )
    }
}
