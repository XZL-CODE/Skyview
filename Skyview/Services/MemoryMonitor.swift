//
//  MemoryMonitor.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import Darwin

class MemoryMonitor {
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
        let free = UInt64(stats.free_count) * pageSize
        let speculative = UInt64(stats.speculative_count) * pageSize

        // 应用内存 = 活跃 + 非活跃 - 已压缩存储的部分
        let appMemory = active + inactive

        // 已使用 = 应用内存 + 已联动 + 已压缩
        let used = appMemory + wired + compressed

        // 实际可用 = 空闲 + 投机性
        let actualFree = free + speculative

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
