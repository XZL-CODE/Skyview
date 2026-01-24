//
//  ByteFormatter.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation

struct ByteFormatter {
    static func format(_ bytes: UInt64, decimals: Int = 1) -> String {
        let units = ["B", "KB", "MB", "GB", "TB", "PB"]
        var value = Double(bytes)
        var unitIndex = 0

        while value >= 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }

        if unitIndex == 0 {
            return String(format: "%.0f %@", value, units[unitIndex])
        }
        return String(format: "%.\(decimals)f %@", value, units[unitIndex])
    }

    static func format(_ bytes: Int64, decimals: Int = 1) -> String {
        return format(UInt64(max(0, bytes)), decimals: decimals)
    }

    static func formatSpeed(_ bytesPerSecond: Double) -> String {
        let units = ["B/s", "KB/s", "MB/s", "GB/s"]
        var value = bytesPerSecond
        var unitIndex = 0

        while value >= 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }

        if unitIndex == 0 {
            return String(format: "%.0f %@", value, units[unitIndex])
        }
        return String(format: "%.1f %@", value, units[unitIndex])
    }

    static func formatPercentage(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
}
