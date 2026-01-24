//
//  SystemInfo.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation

struct SystemInfo {
    var hostname: String
    var osVersion: String
    var kernelVersion: String
    var uptime: TimeInterval
    var modelName: String
    var processorName: String
    var processorCount: Int
    var physicalMemory: UInt64

    static var placeholder: SystemInfo {
        SystemInfo(
            hostname: "MacBook Pro",
            osVersion: "macOS 15.7",
            kernelVersion: "Darwin 24.6.0",
            uptime: 3024000,
            modelName: "MacBook Pro",
            processorName: "Apple M1 Pro",
            processorCount: 10,
            physicalMemory: 16 * 1024 * 1024 * 1024
        )
    }
}
