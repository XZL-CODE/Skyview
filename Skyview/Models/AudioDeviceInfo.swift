//
//  AudioDeviceInfo.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation

nonisolated enum AudioDeviceType: String {
    case input = "输入"
    case output = "输出"
    case systemOutput = "系统输出"
}

nonisolated struct AudioDeviceInfo: Identifiable {
    let id: AudioDeviceID
    var name: String
    var deviceType: AudioDeviceType
    var sampleRate: Double
    var channelCount: Int
    var isDefault: Bool
    var volume: Float?
    var manufacturer: String

    var sampleRateFormatted: String {
        String(format: "%.1f kHz", sampleRate / 1000)
    }

    static var placeholder: AudioDeviceInfo {
        AudioDeviceInfo(
            id: 0,
            name: "MacBook Pro 扬声器",
            deviceType: .output,
            sampleRate: 48000,
            channelCount: 2,
            isDefault: true,
            volume: 0.75,
            manufacturer: "Apple Inc."
        )
    }
}

typealias AudioDeviceID = UInt32
