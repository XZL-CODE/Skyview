//
//  USBMonitor.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import IOKit
import IOKit.usb

nonisolated class USBMonitor {
    func getUSBDevices() -> [USBDeviceInfo] {
        var devices: [USBDeviceInfo] = []

        let matching = IOServiceMatching(kIOUSBDeviceClassName)
        var iterator: io_iterator_t = 0

        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return devices
        }

        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }

            let productName = getStringProperty(service, key: kUSBProductString) ?? getStringProperty(service, key: "USB Product Name")
            let vendor = getStringProperty(service, key: kUSBVendorString) ?? getStringProperty(service, key: "USB Vendor Name")
            let name = productName ?? String(localized: "未知设备")
            let vendorName = vendor ?? String(localized: "未知")
            let productID = getIntProperty(service, key: kUSBProductID) ?? 0
            let vendorID = getIntProperty(service, key: kUSBVendorID) ?? 0
            let serialNumber = getStringProperty(service, key: kUSBSerialNumberString)
            let locationID = UInt32(getIntProperty(service, key: kUSBDevicePropertyLocationID) ?? 0)

            // 获取设备速度
            let speedValue = getIntProperty(service, key: kUSBDevicePropertySpeed) ?? 0
            let speed = speedString(from: speedValue)

            // 获取功耗
            let power = getIntProperty(service, key: "bMaxPower") ?? 0

            // 过滤掉 Hub 设备和内部设备
            let deviceClass = getIntProperty(service, key: kUSBDeviceClass) ?? 0
            if deviceClass == 9 { continue } // USB Hub

            // 只显示有名称的设备
            if productName == nil && vendor == nil { continue }

            let info = USBDeviceInfo(
                name: name,
                vendorName: vendorName,
                productID: productID,
                vendorID: vendorID,
                speed: speed,
                power: power * 2, // bMaxPower 是以 2mA 为单位
                serialNumber: serialNumber,
                locationID: locationID
            )
            devices.append(info)
        }

        return devices
    }

    private func speedString(from value: Int) -> String {
        switch value {
        case 0: return "USB 1.0 (1.5 Mbps)"
        case 1: return "USB 1.1 (12 Mbps)"
        case 2: return "USB 2.0 (480 Mbps)"
        case 3: return "USB 3.0 (5 Gbps)"
        case 4: return "USB 3.1 (10 Gbps)"
        case 5: return "USB 3.2 (20 Gbps)"
        default: return "未知"
        }
    }

    private func getStringProperty(_ service: io_service_t, key: String) -> String? {
        guard let cfProperty = IORegistryEntryCreateCFProperty(
            service,
            key as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() else {
            return nil
        }

        return cfProperty as? String
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

        if let number = cfProperty as? NSNumber {
            return number.intValue
        }
        return cfProperty as? Int
    }
}
