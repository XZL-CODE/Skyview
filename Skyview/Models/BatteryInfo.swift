//
//  BatteryInfo.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation

nonisolated struct BatteryInfo {
    var level: Double               // 电量百分比 0-100
    var isCharging: Bool            // 是否充电中
    var isPluggedIn: Bool           // 是否接入电源
    var cycleCount: Int?            // 循环次数
    var health: Double?             // 电池健康度
    var timeRemaining: Int?         // 剩余时间（分钟）
    var hasBattery: Bool            // 是否有电池

    var statusText: String {
        if !hasBattery {
            return String(localized: "无电池")
        }
        if isCharging {
            return String(localized: "正在充电")
        }
        if isPluggedIn {
            return String(localized: "已充满")
        }
        if let time = timeRemaining, time > 0 {
            let hours = time / 60
            let minutes = time % 60
            return String(localized: "剩余 \(hours):\(String(format: "%02d", minutes))")
        }
        return String(localized: "使用电池")
    }

    static var placeholder: BatteryInfo {
        BatteryInfo(
            level: 85,
            isCharging: false,
            isPluggedIn: true,
            cycleCount: 156,
            health: 92.5,
            timeRemaining: nil,
            hasBattery: true
        )
    }

    static var noBattery: BatteryInfo {
        BatteryInfo(
            level: 100,
            isCharging: false,
            isPluggedIn: true,
            cycleCount: nil,
            health: nil,
            timeRemaining: nil,
            hasBattery: false
        )
    }
}
