//
//  CPUMonitor.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import Darwin

class CPUMonitor {
    private var previousCPUInfo: host_cpu_load_info?
    private var previousPerCoreCPU: [(user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)]?

    // 缓存的静态信息
    private var cachedBrand: String?
    private var cachedArchitecture: String?
    private var cachedL1Cache: UInt64?
    private var cachedL2Cache: UInt64?
    private var cachedL3Cache: UInt64?
    private var cachedPCores: Int?
    private var cachedECores: Int?

    func getCPUInfo() -> CPUInfo {
        let coreCount = ProcessInfo.processInfo.processorCount
        let usage = getCPUUsage()
        let loadAvg = getLoadAverage()
        let perCore = getPerCoreUsage()

        // 获取或缓存静态信息
        if cachedBrand == nil {
            cachedBrand = getProcessorBrand()
            cachedArchitecture = getArchitecture()
            cachedL1Cache = getCacheSize(level: 1)
            cachedL2Cache = getCacheSize(level: 2)
            cachedL3Cache = getCacheSize(level: 3)
            (cachedPCores, cachedECores) = getCoreTypes()
        }

        return CPUInfo(
            usage: usage.total,
            userUsage: usage.user,
            systemUsage: usage.system,
            idleUsage: usage.idle,
            niceUsage: usage.nice,
            coreCount: coreCount,
            temperature: nil,
            performanceCores: cachedPCores ?? coreCount,
            efficiencyCores: cachedECores ?? 0,
            loadAverage1Min: loadAvg.0,
            loadAverage5Min: loadAvg.1,
            loadAverage15Min: loadAvg.2,
            brand: cachedBrand ?? "Unknown",
            architecture: cachedArchitecture ?? "Unknown",
            l1CacheSize: cachedL1Cache ?? 0,
            l2CacheSize: cachedL2Cache ?? 0,
            l3CacheSize: cachedL3Cache ?? 0,
            perCoreUsage: perCore
        )
    }

    private func getCPUUsage() -> (total: Double, user: Double, system: Double, idle: Double, nice: Double) {
        var cpuInfo: host_cpu_load_info?

        let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride

        var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
        var cpuLoadInfo = host_cpu_load_info()

        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }

        guard result == KERN_SUCCESS else {
            return (0, 0, 0, 100, 0)
        }

        cpuInfo = cpuLoadInfo

        guard let current = cpuInfo else {
            return (0, 0, 0, 100, 0)
        }

        let userDiff: Double
        let systemDiff: Double
        let idleDiff: Double
        let niceDiff: Double

        if let previous = previousCPUInfo {
            userDiff = Double(current.cpu_ticks.0 - previous.cpu_ticks.0)
            systemDiff = Double(current.cpu_ticks.1 - previous.cpu_ticks.1)
            idleDiff = Double(current.cpu_ticks.2 - previous.cpu_ticks.2)
            niceDiff = Double(current.cpu_ticks.3 - previous.cpu_ticks.3)
        } else {
            userDiff = Double(current.cpu_ticks.0)
            systemDiff = Double(current.cpu_ticks.1)
            idleDiff = Double(current.cpu_ticks.2)
            niceDiff = Double(current.cpu_ticks.3)
        }

        previousCPUInfo = current

        let totalTicks = userDiff + systemDiff + idleDiff + niceDiff
        guard totalTicks > 0 else {
            return (0, 0, 0, 100, 0)
        }

        let userUsage = userDiff / totalTicks * 100
        let systemUsage = systemDiff / totalTicks * 100
        let idleUsage = idleDiff / totalTicks * 100
        let niceUsage = niceDiff / totalTicks * 100
        let totalUsage = userUsage + systemUsage + niceUsage

        return (totalUsage, userUsage, systemUsage, idleUsage, niceUsage)
    }

    private func getPerCoreUsage() -> [Double] {
        var numCPUs: natural_t = 0
        var cpuInfo: processor_info_array_t?
        var numCPUInfo: mach_msg_type_number_t = 0

        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs, &cpuInfo, &numCPUInfo)

        guard result == KERN_SUCCESS, let cpuInfo = cpuInfo else {
            return []
        }

        defer {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(numCPUInfo) * vm_size_t(MemoryLayout<Int32>.stride))
        }

        var perCoreUsage: [Double] = []
        var currentPerCore: [(user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)] = []

        for i in 0..<Int(numCPUs) {
            let offset = Int32(CPU_STATE_MAX) * Int32(i)
            let user = UInt64(cpuInfo[Int(offset + CPU_STATE_USER)])
            let system = UInt64(cpuInfo[Int(offset + CPU_STATE_SYSTEM)])
            let idle = UInt64(cpuInfo[Int(offset + CPU_STATE_IDLE)])
            let nice = UInt64(cpuInfo[Int(offset + CPU_STATE_NICE)])

            currentPerCore.append((user, system, idle, nice))

            if let prev = previousPerCoreCPU, i < prev.count {
                let userDiff = user > prev[i].user ? Double(user - prev[i].user) : 0
                let systemDiff = system > prev[i].system ? Double(system - prev[i].system) : 0
                let idleDiff = idle > prev[i].idle ? Double(idle - prev[i].idle) : 0
                let niceDiff = nice > prev[i].nice ? Double(nice - prev[i].nice) : 0

                let totalDiff = userDiff + systemDiff + idleDiff + niceDiff
                if totalDiff > 0 {
                    let coreUsage = (userDiff + systemDiff + niceDiff) / totalDiff * 100
                    perCoreUsage.append(coreUsage)
                } else {
                    perCoreUsage.append(0)
                }
            } else {
                perCoreUsage.append(0)
            }
        }

        previousPerCoreCPU = currentPerCore
        return perCoreUsage
    }

    private func getLoadAverage() -> (Double, Double, Double) {
        var loadAvg: [Double] = [0, 0, 0]
        getloadavg(&loadAvg, 3)
        return (loadAvg[0], loadAvg[1], loadAvg[2])
    }

    private func getProcessorBrand() -> String {
        var size: Int = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)

        if size > 0 {
            var brand = [CChar](repeating: 0, count: size)
            sysctlbyname("machdep.cpu.brand_string", &brand, &size, nil, 0)
            return String(cString: brand)
        }

        // Apple Silicon 没有 brand_string
        let coreCount = ProcessInfo.processInfo.processorCount
        if coreCount >= 24 {
            return "Apple M2 Ultra"
        } else if coreCount >= 19 {
            return "Apple M3 Max"
        } else if coreCount >= 12 {
            return "Apple M2 Pro / M3 Pro"
        } else if coreCount >= 10 {
            return "Apple M1 Pro / M2 Pro"
        } else if coreCount >= 8 {
            return "Apple M1 / M2 / M3"
        }
        return "Apple Silicon"
    }

    private func getArchitecture() -> String {
        #if arch(arm64)
        return "ARM64 (Apple Silicon)"
        #elseif arch(x86_64)
        return "x86_64 (Intel)"
        #else
        return "Unknown"
        #endif
    }

    private func getCacheSize(level: Int) -> UInt64 {
        var size: UInt64 = 0
        var len = MemoryLayout<UInt64>.size

        let key: String
        switch level {
        case 1:
            key = "hw.l1dcachesize"
        case 2:
            key = "hw.l2cachesize"
        case 3:
            key = "hw.l3cachesize"
        default:
            return 0
        }

        if sysctlbyname(key, &size, &len, nil, 0) == 0 {
            return size
        }
        return 0
    }

    private func getCoreTypes() -> (performance: Int, efficiency: Int) {
        var pCores: Int32 = 0
        var eCores: Int32 = 0
        var size = MemoryLayout<Int32>.size

        // Apple Silicon 特有的 sysctl
        if sysctlbyname("hw.perflevel0.physicalcpu", &pCores, &size, nil, 0) == 0 {
            size = MemoryLayout<Int32>.size
            sysctlbyname("hw.perflevel1.physicalcpu", &eCores, &size, nil, 0)
            return (Int(pCores), Int(eCores))
        }

        // 非 Apple Silicon，所有核心都是性能核心
        return (ProcessInfo.processInfo.processorCount, 0)
    }
}
