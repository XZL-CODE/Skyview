//
//  SettingsKeys.swift
//  Skyview
//
//  Created by xzl on 2026/6/10.
//

import Foundation

/// UserDefaults 键名统一管理
enum SettingsKeys {
    static let showMenuBarExtra = "showMenuBarExtra"
    static let menuBarStyle = "menuBarStyle"
    static let throttleWhenInactive = "throttleWhenInactive"
    static let alertsEnabled = "alertsEnabled"
    static let alertCPUThreshold = "alertCPUThreshold"
    static let alertMemoryThreshold = "alertMemoryThreshold"
    static let alertDiskFreeThreshold = "alertDiskFreeThreshold"

    /// 注册默认值, 应用启动时调用一次
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            showMenuBarExtra: true,
            menuBarStyle: MenuBarStyle.cpu.rawValue,
            throttleWhenInactive: true,
            alertsEnabled: false,
            alertCPUThreshold: 90.0,
            alertMemoryThreshold: 90.0,
            alertDiskFreeThreshold: 10.0,
        ])
    }
}

/// 菜单栏标签显示内容
enum MenuBarStyle: String, CaseIterable, Identifiable {
    case cpu
    case memory
    case both

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cpu: return String(localized: "CPU 使用率")
        case .memory: return String(localized: "内存使用率")
        case .both: return String(localized: "CPU + 内存")
        }
    }
}
