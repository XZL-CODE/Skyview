//
//  StorageMonitor.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation

nonisolated class StorageMonitor {
    func getStorageInfo() -> StorageInfo {
        let fileManager = FileManager.default
        let homeURL = fileManager.homeDirectoryForCurrentUser

        do {
            let values = try homeURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityForImportantUsageKey,
                .volumeNameKey
            ])

            let total = UInt64(values.volumeTotalCapacity ?? 0)
            let free = UInt64(values.volumeAvailableCapacityForImportantUsage ?? 0)
            let used = total > free ? total - free : 0
            let volumeName = values.volumeName ?? "Macintosh HD"

            return StorageInfo(
                total: total,
                used: used,
                free: free,
                volumeName: volumeName
            )
        } catch {
            return StorageInfo.placeholder
        }
    }
}
