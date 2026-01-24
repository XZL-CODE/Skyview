//
//  BatteryMonitor.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import IOKit.ps

class BatteryMonitor {
    func getBatteryInfo() -> BatteryInfo {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array

        guard sources.count > 0,
              let info = IOPSGetPowerSourceDescription(snapshot, sources[0]).takeUnretainedValue() as? [String: Any] else {
            return BatteryInfo.noBattery
        }

        let type = info[kIOPSTypeKey] as? String ?? ""
        guard type == kIOPSInternalBatteryType else {
            return BatteryInfo.noBattery
        }

        let currentCapacity = info[kIOPSCurrentCapacityKey] as? Int ?? 0
        let maxCapacity = info[kIOPSMaxCapacityKey] as? Int ?? 100
        let isCharging = info[kIOPSIsChargingKey] as? Bool ?? false
        let powerSource = info[kIOPSPowerSourceStateKey] as? String ?? ""
        let isPluggedIn = powerSource == kIOPSACPowerValue

        var timeRemaining: Int? = nil
        if let time = info[kIOPSTimeToEmptyKey] as? Int, time > 0 {
            timeRemaining = time
        } else if let time = info[kIOPSTimeToFullChargeKey] as? Int, time > 0 && isCharging {
            timeRemaining = time
        }

        let level = maxCapacity > 0 ? Double(currentCapacity) / Double(maxCapacity) * 100 : 0

        // 电池健康度和循环次数需要通过 IOKit 深层访问
        let (cycleCount, health) = getBatteryHealthInfo()

        return BatteryInfo(
            level: level,
            isCharging: isCharging,
            isPluggedIn: isPluggedIn,
            cycleCount: cycleCount,
            health: health,
            timeRemaining: timeRemaining,
            hasBattery: true
        )
    }

    private func getBatteryHealthInfo() -> (cycleCount: Int?, health: Double?) {
        let service = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("AppleSmartBattery")
        )

        guard service != 0 else {
            return (nil, nil)
        }

        defer { IOObjectRelease(service) }

        var cycleCount: Int? = nil
        var health: Double? = nil

        // 获取循环次数
        cycleCount = getIntProperty(service, key: "CycleCount")

        // 尝试获取电池健康度
        // 方法1: 直接获取 BatteryHealth (部分系统支持)
        if let directHealth = getIntProperty(service, key: "BatteryHealth") {
            health = Double(directHealth)
        }
        // 方法2: Apple Silicon - 从 BatteryData 字典获取 FccComp1
        // FccComp1 / 6400 * 100 = 系统设置显示的健康度百分比
        else if let batteryData = IORegistryEntryCreateCFProperty(
            service,
            "BatteryData" as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? [String: Any],
                let fccComp1 = batteryData["FccComp1"] as? Int {
            // 6400 是 Apple 内部使用的参考容量标准
            health = Double(fccComp1) / 6400.0 * 100.0
        }
        // 方法3 (Fallback): AppleRawMaxCapacity / DesignCapacity
        else if let rawMax = getIntProperty(service, key: "AppleRawMaxCapacity"),
                let designCap = getIntProperty(service, key: "DesignCapacity"),
                designCap > 0 {
            health = Double(rawMax) / Double(designCap) * 100
        }
        // 方法4 (Fallback): Intel Mac - MaxCapacity / DesignCapacity
        else if let maxCap = getIntProperty(service, key: "MaxCapacity"),
                let designCap = getIntProperty(service, key: "DesignCapacity"),
                designCap > 0 {
            health = Double(maxCap) / Double(designCap) * 100
        }
        // 方法5 (Fallback): NominalChargeCapacity
        else if let nominalCap = getIntProperty(service, key: "NominalChargeCapacity"),
                let designCap = getIntProperty(service, key: "DesignCapacity"),
                designCap > 0 {
            health = Double(nominalCap) / Double(designCap) * 100
        }

        return (cycleCount, health)
    }

    private func getIntProperty(_ service: io_service_t, key: String) -> Int? {
        guard let cfProperty = IORegistryEntryCreateCFProperty(
            service,
            key as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() else {
            return nil
        }

        // 处理 NSNumber 类型转换
        if let number = cfProperty as? NSNumber {
            return number.intValue
        }
        if let intValue = cfProperty as? Int {
            return intValue
        }
        return nil
    }
}
