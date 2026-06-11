//
//  DiskIOMonitor.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import IOKit

nonisolated class DiskIOMonitor {
    private var previousBytesRead: UInt64 = 0
    private var previousBytesWritten: UInt64 = 0
    private var previousReadOps: UInt64 = 0
    private var previousWriteOps: UInt64 = 0
    private var previousTime: Date?

    func getDiskIOInfo() -> DiskIOInfo {
        let (bytesRead, bytesWritten, readOps, writeOps) = getDiskStatistics()
        let currentTime = Date()

        var readSpeed: Double = 0
        var writeSpeed: Double = 0

        if let prevTime = previousTime {
            let timeDiff = currentTime.timeIntervalSince(prevTime)
            if timeDiff > 0 {
                let readDiff = bytesRead > previousBytesRead ? bytesRead - previousBytesRead : 0
                let writeDiff = bytesWritten > previousBytesWritten ? bytesWritten - previousBytesWritten : 0

                readSpeed = Double(readDiff) / timeDiff
                writeSpeed = Double(writeDiff) / timeDiff
            }
        }

        previousBytesRead = bytesRead
        previousBytesWritten = bytesWritten
        previousReadOps = readOps
        previousWriteOps = writeOps
        previousTime = currentTime

        return DiskIOInfo(
            bytesRead: bytesRead,
            bytesWritten: bytesWritten,
            readSpeed: readSpeed,
            writeSpeed: writeSpeed,
            readOps: readOps,
            writeOps: writeOps,
            lastUpdate: currentTime
        )
    }

    private func getDiskStatistics() -> (bytesRead: UInt64, bytesWritten: UInt64, readOps: UInt64, writeOps: UInt64) {
        var totalBytesRead: UInt64 = 0
        var totalBytesWritten: UInt64 = 0
        var totalReadOps: UInt64 = 0
        var totalWriteOps: UInt64 = 0

        let matching = IOServiceMatching("IOBlockStorageDriver")
        var iterator: io_iterator_t = 0

        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return (0, 0, 0, 0)
        }

        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }

            guard let propertiesRef = IORegistryEntryCreateCFProperty(
                service,
                "Statistics" as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue() as? [String: Any] else {
                continue
            }

            if let bytesRead = propertiesRef["Bytes (Read)"] as? UInt64 {
                totalBytesRead += bytesRead
            }
            if let bytesWritten = propertiesRef["Bytes (Write)"] as? UInt64 {
                totalBytesWritten += bytesWritten
            }
            if let readOps = propertiesRef["Operations (Read)"] as? UInt64 {
                totalReadOps += readOps
            }
            if let writeOps = propertiesRef["Operations (Write)"] as? UInt64 {
                totalWriteOps += writeOps
            }
        }

        return (totalBytesRead, totalBytesWritten, totalReadOps, totalWriteOps)
    }
}
