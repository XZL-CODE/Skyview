//
//  USBDeviceInfo.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation

nonisolated struct USBDeviceInfo: Identifiable {
    let id = UUID()
    var name: String
    var vendorName: String
    var productID: Int
    var vendorID: Int
    var speed: String
    var power: Int  // mA
    var serialNumber: String?
    var locationID: UInt32

    var powerFormatted: String {
        "\(power) mA"
    }

    static var placeholder: USBDeviceInfo {
        USBDeviceInfo(
            name: "USB 设备",
            vendorName: "Apple Inc.",
            productID: 0x1234,
            vendorID: 0x05AC,
            speed: "USB 3.0",
            power: 500,
            serialNumber: nil,
            locationID: 0
        )
    }
}
