//
//  StorageInfo.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation

nonisolated struct StorageInfo {
    var total: UInt64
    var used: UInt64
    var free: UInt64
    var volumeName: String

    var usagePercentage: Double {
        guard total > 0 else { return 0 }
        return Double(used) / Double(total) * 100
    }

    static var placeholder: StorageInfo {
        StorageInfo(
            total: 500 * 1024 * 1024 * 1024,
            used: 350 * 1024 * 1024 * 1024,
            free: 150 * 1024 * 1024 * 1024,
            volumeName: "Macintosh HD"
        )
    }
}
