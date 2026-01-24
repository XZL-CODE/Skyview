//
//  ProcessMonitor.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import Darwin

class ProcessMonitor {
    private var previousCPUTimes: [Int32: (user: UInt64, system: UInt64)] = [:]
    private var previousUpdateTime: Date?

    func getTopProcesses(limit: Int = 10, sortBy: ProcessSortOrder = .cpu) -> [ProcessInfoItem] {
        var processes: [ProcessInfoItem] = []

        // 获取所有进程 ID
        var pids = [Int32](repeating: 0, count: 4096)
        let pidCount = proc_listpids(UInt32(PROC_ALL_PIDS), 0, &pids, Int32(pids.count * MemoryLayout<Int32>.stride))

        guard pidCount > 0 else { return processes }

        let actualPidCount = Int(pidCount) / MemoryLayout<Int32>.stride
        let currentTime = Date()

        for i in 0..<actualPidCount {
            let pid = pids[i]
            if pid == 0 { continue }

            guard let info = getProcessInfo(pid: pid, currentTime: currentTime) else { continue }
            processes.append(info)
        }

        previousUpdateTime = currentTime

        // 按指定方式排序并返回前 N 个
        switch sortBy {
        case .cpu:
            processes.sort { $0.cpuUsage > $1.cpuUsage }
        case .memory:
            processes.sort { $0.memoryUsage > $1.memoryUsage }
        }

        return Array(processes.prefix(limit))
    }

    private func getProcessInfo(pid: Int32, currentTime: Date) -> ProcessInfoItem? {
        // 获取进程基本信息
        var taskInfo = proc_taskallinfo()
        let infoSize = Int32(MemoryLayout<proc_taskallinfo>.stride)

        let result = proc_pidinfo(pid, PROC_PIDTASKALLINFO, 0, &taskInfo, infoSize)
        guard result == infoSize else { return nil }

        // 获取进程名称
        var pathBuffer = [CChar](repeating: 0, count: Int(MAXPATHLEN))
        proc_pidpath(pid, &pathBuffer, UInt32(MAXPATHLEN))
        var name = String(cString: pathBuffer)
        if name.isEmpty {
            // 尝试从 taskInfo 获取名称
            let nameBytes = withUnsafeBytes(of: taskInfo.pbsd.pbi_name) { Array($0) }
            if let terminatorIndex = nameBytes.firstIndex(of: 0) {
                name = String(bytes: nameBytes[..<terminatorIndex], encoding: .utf8) ?? ""
            }
        } else {
            // 从路径中提取文件名
            name = (name as NSString).lastPathComponent
        }

        if name.isEmpty { return nil }

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

        // 获取用户名
        let uid = taskInfo.pbsd.pbi_uid
        var user = "uid:\(uid)"
        if let pw = getpwuid(uid) {
            user = String(cString: pw.pointee.pw_name)
        }

        // 获取线程数
        let threads = Int32(taskInfo.ptinfo.pti_threadnum)

        return ProcessInfoItem(
            pid: pid,
            name: name,
            cpuUsage: min(cpuUsage, 100 * Double(ProcessInfo.processInfo.processorCount)),
            memoryUsage: memoryUsage,
            user: user,
            threads: threads
        )
    }
}

enum ProcessSortOrder {
    case cpu
    case memory
}
