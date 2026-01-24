//
//  ApplicationMonitor.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import AppKit
import Darwin

class ApplicationMonitor {
    private var previousCPUTimes: [Int32: (user: UInt64, system: UInt64)] = [:]
    private var previousUpdateTime: Date?

    /// 获取 Top N 内存消耗应用
    func getTopMemoryApps(limit: Int = 10) -> [AppInfo] {
        let apps = getRunningApps()
        return Array(apps.sorted { $0.memoryUsage > $1.memoryUsage }.prefix(limit))
    }

    /// 获取 Top N CPU 消耗应用
    func getTopCPUApps(limit: Int = 10) -> [AppInfo] {
        let apps = getRunningApps()
        return Array(apps.sorted { $0.cpuUsage > $1.cpuUsage }.prefix(limit))
    }

    /// 获取所有运行中的应用（排序由调用者决定）
    func getRunningApps() -> [AppInfo] {
        var apps: [AppInfo] = []
        let currentTime = Date()

        // 使用 NSWorkspace 获取真正的"应用"列表
        let runningApps = NSWorkspace.shared.runningApplications

        for app in runningApps {
            // 只处理常规应用（排除后台代理等）
            guard app.activationPolicy == .regular else { continue }

            let pid = app.processIdentifier
            guard let appInfo = getAppResourceInfo(
                pid: pid,
                name: app.localizedName ?? "Unknown",
                bundleIdentifier: app.bundleIdentifier,
                icon: app.icon,
                currentTime: currentTime
            ) else { continue }

            apps.append(appInfo)
        }

        previousUpdateTime = currentTime
        return apps
    }

    private func getAppResourceInfo(
        pid: Int32,
        name: String,
        bundleIdentifier: String?,
        icon: NSImage?,
        currentTime: Date
    ) -> AppInfo? {
        // 获取进程资源信息
        var taskInfo = proc_taskallinfo()
        let infoSize = Int32(MemoryLayout<proc_taskallinfo>.stride)

        let result = proc_pidinfo(pid, PROC_PIDTASKALLINFO, 0, &taskInfo, infoSize)
        guard result == infoSize else { return nil }

        // 计算 CPU 使用率
        let userTime = UInt64(taskInfo.ptinfo.pti_total_user)
        let systemTime = UInt64(taskInfo.ptinfo.pti_total_system)
        var cpuUsage: Double = 0

        if let previousTime = previousCPUTimes[pid],
           let prevUpdateTime = previousUpdateTime {
            let timeDiff = currentTime.timeIntervalSince(prevUpdateTime)
            if timeDiff > 0 {
                let userDiff = userTime > previousTime.user ? userTime - previousTime.user : 0
                let systemDiff = systemTime > previousTime.system ? systemTime - previousTime.system : 0
                let totalDiff = Double(userDiff + systemDiff)

                // 转换为百分比 (时间单位是纳秒)
                cpuUsage = (totalDiff / 1_000_000_000) / timeDiff * 100
            }
        }

        previousCPUTimes[pid] = (userTime, systemTime)

        // 获取内存使用
        let memoryUsage = UInt64(taskInfo.ptinfo.pti_resident_size)

        // 获取线程数
        let threads = Int32(taskInfo.ptinfo.pti_threadnum)

        return AppInfo(
            pid: pid,
            name: name,
            bundleIdentifier: bundleIdentifier,
            icon: icon,
            memoryUsage: memoryUsage,
            cpuUsage: min(cpuUsage, 100 * Double(ProcessInfo.processInfo.processorCount)),
            threads: threads
        )
    }

    /// 清理不再运行的进程的 CPU 时间记录
    func cleanupStaleData() {
        let runningPids = Set(NSWorkspace.shared.runningApplications.map { $0.processIdentifier })
        previousCPUTimes = previousCPUTimes.filter { runningPids.contains($0.key) }
    }
}
