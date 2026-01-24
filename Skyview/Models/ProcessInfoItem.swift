//
//  ProcessInfoItem.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation

struct ProcessInfoItem: Identifiable {
    var id: Int32 { pid }
    var pid: Int32
    var name: String
    var cpuUsage: Double        // CPU 使用率 %
    var memoryUsage: UInt64     // 内存占用 bytes
    var user: String
    var threads: Int32

    var memoryFormatted: String {
        ByteFormatter.format(memoryUsage)
    }

    var cpuFormatted: String {
        String(format: "%.1f%%", cpuUsage)
    }

    static var placeholder: ProcessInfoItem {
        ProcessInfoItem(
            pid: 1,
            name: "kernel_task",
            cpuUsage: 5.0,
            memoryUsage: 1024 * 1024 * 100,
            user: "root",
            threads: 100
        )
    }
}
