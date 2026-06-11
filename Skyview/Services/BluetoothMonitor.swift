//
//  BluetoothMonitor.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import IOBluetooth

nonisolated class BluetoothMonitor {
    func getBluetoothDevices() -> [BluetoothDeviceInfo] {
        var devices: [BluetoothDeviceInfo] = []

        // 获取所有已配对设备
        guard let pairedDevices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] else {
            return devices
        }

        for device in pairedDevices {
            let name = device.name ?? String(localized: "未知设备")
            let address = device.addressString ?? "00:00:00:00:00:00"
            let isConnected = device.isConnected()
            let rssi = Int(device.rawRSSI())

            // 获取设备类型
            let deviceType = getDeviceTypeString(classOfDevice: device.classOfDevice)

            // 尝试获取电量 (仅部分设备支持)
            let batteryLevel: Int? = nil
            // 注意: IOBluetooth 直接获取电量比较复杂，部分设备不支持

            let info = BluetoothDeviceInfo(
                name: name,
                address: address,
                isConnected: isConnected,
                isPaired: true,
                rssi: rssi,
                deviceType: deviceType,
                batteryLevel: batteryLevel,
                lastSeen: isConnected ? Date() : device.recentAccessDate()
            )
            devices.append(info)
        }

        return devices
    }

    func isBluetoothEnabled() -> Bool {
        return IOBluetoothHostController.default()?.powerState == kBluetoothHCIPowerStateON
    }

    private func getDeviceTypeString(classOfDevice: BluetoothClassOfDevice) -> String {
        let majorClass = (classOfDevice >> 8) & 0x1F

        switch majorClass {
        case 1:
            return String(localized: "电脑")
        case 2:
            return String(localized: "手机")
        case 3:
            return String(localized: "网络接入点")
        case 4:
            // 音频/视频设备
            let minorClass = (classOfDevice >> 2) & 0x3F
            switch minorClass {
            case 1: return String(localized: "耳机")
            case 2: return String(localized: "免提设备")
            case 4: return String(localized: "麦克风")
            case 5: return String(localized: "扬声器")
            case 6: return String(localized: "耳机")
            case 7: return String(localized: "便携式音频")
            case 8: return String(localized: "汽车音响")
            default: return String(localized: "音频设备")
            }
        case 5:
            // 外设
            let minorClass = (classOfDevice >> 2) & 0x3F
            switch minorClass {
            case 1: return String(localized: "键盘")
            case 2: return String(localized: "鼠标")
            case 3: return String(localized: "键鼠套装")
            case 5: return String(localized: "游戏手柄")
            default: return String(localized: "外设")
            }
        case 6:
            return String(localized: "打印机")
        case 7:
            return String(localized: "可穿戴设备")
        default:
            return String(localized: "其他设备")
        }
    }
}
