//
//  AppInfo.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import AppKit

nonisolated struct AppInfo: Identifiable {
    let id = UUID()
    var pid: Int32
    var name: String                    // 应用名称
    var bundleIdentifier: String?       // Bundle ID
    var icon: NSImage?                  // 应用图标
    var memoryUsage: UInt64             // 内存占用 bytes
    var cpuUsage: Double                // CPU 使用率 %
    var threads: Int32                  // 线程数

    var memoryFormatted: String {
        ByteFormatter.format(memoryUsage)
    }

    var cpuFormatted: String {
        String(format: "%.1f%%", cpuUsage)
    }

    static var placeholder: AppInfo {
        AppInfo(
            pid: 1,
            name: "Safari",
            bundleIdentifier: "com.apple.Safari",
            icon: nil,
            memoryUsage: 1024 * 1024 * 500,
            cpuUsage: 3.5,
            threads: 20
        )
    }
}

nonisolated enum AppSortOrder {
    case memory
    case cpu
}
