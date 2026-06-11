//
//  BluetoothDeviceInfo.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation

nonisolated struct BluetoothDeviceInfo: Identifiable {
    let id = UUID()
    var name: String
    var address: String
    var isConnected: Bool
    var isPaired: Bool
    var rssi: Int               // 信号强度
    var deviceType: String      // 设备类型
    var batteryLevel: Int?      // 电量百分比 (如果支持)
    var lastSeen: Date?

    var rssiDescription: String {
        if rssi >= -50 {
            return String(localized: "极好")
        } else if rssi >= -60 {
            return String(localized: "很好")
        } else if rssi >= -70 {
            return String(localized: "良好")
        } else if rssi >= -80 {
            return String(localized: "一般")
        } else {
            return String(localized: "较弱")
        }
    }

    var batteryFormatted: String? {
        guard let level = batteryLevel else { return nil }
        return "\(level)%"
    }

    static var placeholder: BluetoothDeviceInfo {
        BluetoothDeviceInfo(
            name: "AirPods Pro",
            address: "00:00:00:00:00:00",
            isConnected: true,
            isPaired: true,
            rssi: -45,
            deviceType: "耳机",
            batteryLevel: 85,
            lastSeen: Date()
        )
    }
}
