//
//  MemoryMonitor.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import Darwin

nonisolated class MemoryMonitor {
    func getMemoryInfo() -> MemoryInfo {
        let totalMemory = ProcessInfo.processInfo.physicalMemory

        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return MemoryInfo.placeholder
        }

        let pageSize = UInt64(vm_kernel_page_size)

        let active = UInt64(stats.active_count) * pageSize
        let inactive = UInt64(stats.inactive_count) * pageSize
        let wired = UInt64(stats.wire_count) * pageSize
        let compressed = UInt64(stats.compressor_page_count) * pageSize

        // 与活动监视器同口径:
        // 应用内存 = 匿名页 (internal) 减去可清除部分 (purgeable)
        let internalBytes = UInt64(stats.internal_page_count) * pageSize
        let purgeable = UInt64(stats.purgeable_count) * pageSize
        let appMemory = internalBytes > purgeable ? internalBytes - purgeable : 0

        // 已使用 = 应用内存 + 已联动 + 已压缩
        // 注意: 不把 inactive 文件缓存算进"已使用"，它可被系统随时回收
        let used = appMemory + wired + compressed

        // 可用 = 总量 - 已使用 (含可立即回收的缓存)
        let actualFree = totalMemory > used ? totalMemory - used : 0

        return MemoryInfo(
            total: totalMemory,
            used: used,
            free: actualFree,
            active: active,
            inactive: inactive,
            wired: wired,
            compressed: compressed,
            appMemory: appMemory
        )
    }
}
