//
//  BatteryInfo.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation

struct BatteryInfo {
    var level: Double               // 电量百分比 0-100
    var isCharging: Bool            // 是否充电中
    var isPluggedIn: Bool           // 是否接入电源
    var cycleCount: Int?            // 循环次数
    var health: Double?             // 电池健康度
    var timeRemaining: Int?         // 剩余时间（分钟）
    var hasBattery: Bool            // 是否有电池

    var statusText: String {
        if !hasBattery {
            return "无电池"
        }
        if isCharging {
            return "正在充电"
        }
        if isPluggedIn {
            return "已充满"
        }
        if let time = timeRemaining, time > 0 {
            let hours = time / 60
            let minutes = time % 60
            return "剩余 \(hours):\(String(format: "%02d", minutes))"
        }
        return "使用电池"
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
