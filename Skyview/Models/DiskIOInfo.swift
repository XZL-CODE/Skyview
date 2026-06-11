//
//  DiskIOInfo.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation

nonisolated struct DiskIOInfo {
    var bytesRead: UInt64
    var bytesWritten: UInt64
    var readSpeed: Double       // bytes/s
    var writeSpeed: Double      // bytes/s
    var readOps: UInt64
    var writeOps: UInt64
    var lastUpdate: Date

    var readSpeedFormatted: String {
        ByteFormatter.formatSpeed(readSpeed)
    }

    var writeSpeedFormatted: String {
        ByteFormatter.formatSpeed(writeSpeed)
    }

    var totalBytesReadFormatted: String {
        ByteFormatter.format(bytesRead)
    }

    var totalBytesWrittenFormatted: String {
        ByteFormatter.format(bytesWritten)
    }

    static var placeholder: DiskIOInfo {
        DiskIOInfo(
            bytesRead: 0,
            bytesWritten: 0,
            readSpeed: 0,
            writeSpeed: 0,
            readOps: 0,
            writeOps: 0,
            lastUpdate: Date()
        )
    }
}
