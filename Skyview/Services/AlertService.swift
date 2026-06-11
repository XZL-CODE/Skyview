//
//  AlertService.swift
//  Skyview
//
//  Created by xzl on 2026/6/10.
//

import Foundation
import UserNotifications

/// 阈值告警: 对采集结果做越界判断, 通过系统通知提醒。
/// 自带两层防刷屏: 同类告警 5 分钟冷却 + CPU 需连续越界约 10 秒才触发。
final class AlertService {
    private enum Kind: String {
        case cpuHigh = "alert.cpu.high"
        case memoryHigh = "alert.memory.high"
        case diskLow = "alert.disk.low"
    }

    /// 同类告警最短间隔
    private let cooldown: TimeInterval = 5 * 60
    /// CPU 需连续越界的采样数 (1s 一采约 10 秒), 避免瞬时尖峰误报
    private let cpuSustainSamples = 10

    private var lastFired: [Kind: Date] = [:]
    private var cpuOverCount = 0

    private var defaults: UserDefaults { .standard }

    /// 随每次指标更新在主线程调用, 传 nil 的域跳过检查
    func evaluate(cpu: CPUInfo?, memory: MemoryInfo?, storage: StorageInfo?) {
        guard defaults.bool(forKey: SettingsKeys.alertsEnabled) else { return }

        if let cpu {
            let threshold = defaults.double(forKey: SettingsKeys.alertCPUThreshold)
            if cpu.usage > threshold {
                cpuOverCount += 1
                if cpuOverCount >= cpuSustainSamples {
                    fire(.cpuHigh,
                         title: String(localized: "CPU 使用率过高"),
                         body: String(format: String(localized: "CPU 已持续超过 %.0f%%，当前 %.0f%%。"), threshold, cpu.usage))
                }
            } else {
                cpuOverCount = 0
            }
        }

        if let memory {
            let threshold = defaults.double(forKey: SettingsKeys.alertMemoryThreshold)
            if memory.usagePercentage > threshold {
                fire(.memoryHigh,
                     title: String(localized: "内存压力高"),
                     body: String(format: String(localized: "内存使用率 %.0f%%，已超过阈值 %.0f%%。"), memory.usagePercentage, threshold))
            }
        }

        if let storage {
            let threshold = defaults.double(forKey: SettingsKeys.alertDiskFreeThreshold)
            let freePercentage = storage.total > 0
                ? Double(storage.free) / Double(storage.total) * 100
                : 100
            if freePercentage < threshold {
                fire(.diskLow,
                     title: String(localized: "磁盘空间不足"),
                     body: String(format: String(localized: "启动磁盘仅剩 %@（%.1f%%）。"), ByteFormatter.format(storage.free), freePercentage))
            }
        }
    }

    /// 用户在设置中开启告警时调用
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func fire(_ kind: Kind, title: String, body: String) {
        let now = Date()
        if let last = lastFired[kind], now.timeIntervalSince(last) < cooldown {
            return
        }
        lastFired[kind] = now
        if kind == .cpuHigh {
            cpuOverCount = 0
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "\(kind.rawValue).\(now.timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
