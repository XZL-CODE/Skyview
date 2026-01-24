//
//  Extensions.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let cardBackground = Color(NSColor.controlBackgroundColor)
    static let cardBorder = Color(NSColor.separatorColor)

    static let cpuGradientStart = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let cpuGradientEnd = Color(red: 0.4, green: 0.2, blue: 0.9)

    static let memoryGradientStart = Color(red: 0.3, green: 0.8, blue: 0.5)
    static let memoryGradientEnd = Color(red: 0.1, green: 0.6, blue: 0.4)

    static let gpuGradientStart = Color(red: 0.9, green: 0.3, blue: 0.5)
    static let gpuGradientEnd = Color(red: 0.7, green: 0.2, blue: 0.8)

    static let storageGradientStart = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let storageGradientEnd = Color(red: 0.9, green: 0.3, blue: 0.3)

    static let diskIOGradientStart = Color(red: 0.2, green: 0.7, blue: 0.9)
    static let diskIOGradientEnd = Color(red: 0.1, green: 0.5, blue: 0.7)

    static let networkGradientStart = Color(red: 0.6, green: 0.4, blue: 0.9)
    static let networkGradientEnd = Color(red: 0.9, green: 0.4, blue: 0.6)

    static let processGradientStart = Color(red: 0.95, green: 0.5, blue: 0.2)
    static let processGradientEnd = Color(red: 0.85, green: 0.3, blue: 0.4)

    static let displayGradientStart = Color(red: 0.4, green: 0.6, blue: 0.9)
    static let displayGradientEnd = Color(red: 0.2, green: 0.4, blue: 0.8)

    static let audioGradientStart = Color(red: 0.9, green: 0.4, blue: 0.7)
    static let audioGradientEnd = Color(red: 0.7, green: 0.3, blue: 0.9)

    static let usbGradientStart = Color(red: 0.3, green: 0.7, blue: 0.5)
    static let usbGradientEnd = Color(red: 0.2, green: 0.5, blue: 0.6)

    static let bluetoothGradientStart = Color(red: 0.0, green: 0.5, blue: 1.0)
    static let bluetoothGradientEnd = Color(red: 0.2, green: 0.3, blue: 0.8)

    static let batteryGradientStart = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let batteryGradientEnd = Color(red: 0.1, green: 0.5, blue: 0.3)

    static let systemGradientStart = Color(red: 0.5, green: 0.5, blue: 0.6)
    static let systemGradientEnd = Color(red: 0.3, green: 0.3, blue: 0.4)

    static let appGradientStart = Color(red: 0.4, green: 0.7, blue: 0.95)
    static let appGradientEnd = Color(red: 0.2, green: 0.5, blue: 0.85)
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - TimeInterval Extensions
extension TimeInterval {
    func formatUptime() -> String {
        let days = Int(self) / 86400
        let hours = (Int(self) % 86400) / 3600
        let minutes = (Int(self) % 3600) / 60

        if days > 0 {
            return "\(days)天 \(hours)小时"
        } else if hours > 0 {
            return "\(hours)小时 \(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
}

// MARK: - Ring Buffer for History Data
struct RingBuffer<T> {
    private var array: [T]
    private var writeIndex = 0
    private(set) var count = 0
    let capacity: Int

    init(capacity: Int, defaultValue: T) {
        self.capacity = capacity
        self.array = Array(repeating: defaultValue, count: capacity)
    }

    mutating func append(_ element: T) {
        array[writeIndex] = element
        writeIndex = (writeIndex + 1) % capacity
        count = min(count + 1, capacity)
    }

    func toArray() -> [T] {
        if count < capacity {
            return Array(array.prefix(count))
        }
        let part1 = Array(array[writeIndex...])
        let part2 = Array(array[..<writeIndex])
        return part1 + part2
    }
}
