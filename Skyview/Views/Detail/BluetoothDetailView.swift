//
//  BluetoothDetailView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct BluetoothDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var connectedDevices: [BluetoothDeviceInfo] {
        manager.bluetoothDevices.filter { $0.isConnected }
    }

    var pairedDevices: [BluetoothDeviceInfo] {
        manager.bluetoothDevices.filter { !$0.isConnected }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "蓝牙设备",
                    subtitle: "\(connectedDevices.count) 已连接 · \(manager.bluetoothDevices.count) 已配对",
                    icon: "wave.3.right",
                    gradient: [.bluetoothGradientStart, .bluetoothGradientEnd]
                )

                // 已连接设备
                if !connectedDevices.isEmpty {
                    BluetoothSectionView(
                        title: "已连接",
                        icon: "checkmark.circle.fill",
                        devices: connectedDevices,
                        isConnected: true
                    )
                }

                // 已配对但未连接的设备
                if !pairedDevices.isEmpty {
                    BluetoothSectionView(
                        title: "已配对",
                        icon: "link",
                        devices: pairedDevices,
                        isConnected: false
                    )
                }

                if manager.bluetoothDevices.isEmpty {
                    EmptyStateView(
                        icon: "wave.3.right",
                        title: "未检测到蓝牙设备",
                        message: "请确保蓝牙已开启并配对设备"
                    )
                }
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct BluetoothSectionView: View {
    let title: String
    let icon: String
    let devices: [BluetoothDeviceInfo]
    let isConnected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isConnected ? .bluetoothGradientStart : .gray)

                Text(title)
                    .font(.headline)

                Spacer()

                Text("\(devices.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }

            ForEach(devices) { device in
                BluetoothDeviceCardView(device: device)
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct BluetoothDeviceCardView: View {
    let device: BluetoothDeviceInfo

    var deviceIcon: String {
        let type = device.deviceType.lowercased()
        if type.contains("耳机") || type.contains("音频") {
            return "headphones"
        } else if type.contains("键盘") {
            return "keyboard"
        } else if type.contains("鼠标") {
            return "computermouse"
        } else if type.contains("手机") {
            return "iphone"
        } else if type.contains("电脑") {
            return "laptopcomputer"
        } else if type.contains("游戏") {
            return "gamecontroller"
        } else if type.contains("扬声器") {
            return "hifispeaker"
        } else {
            return "wave.3.right"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // 设备图标
            ZStack {
                Circle()
                    .fill(device.isConnected ? Color.bluetoothGradientStart.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 48, height: 48)

                Image(systemName: deviceIcon)
                    .font(.system(size: 20))
                    .foregroundColor(device.isConnected ? .bluetoothGradientStart : .gray)
            }

            // 设备信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(device.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if device.isConnected {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                }

                Text(device.deviceType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 电量 (如果有)
            if let battery = device.batteryFormatted {
                HStack(spacing: 4) {
                    Image(systemName: batteryIcon(for: device.batteryLevel ?? 0))
                        .foregroundColor(batteryColor(for: device.batteryLevel ?? 0))

                    Text(battery)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
            }

            // 信号强度
            if device.isConnected {
                VStack(alignment: .trailing, spacing: 2) {
                    SignalStrengthIndicator(rssi: device.rssi)

                    Text(device.rssiDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else if let lastSeen = device.lastSeen {
                Text(formatLastSeen(lastSeen))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    private func batteryIcon(for level: Int) -> String {
        if level > 75 { return "battery.100" }
        if level > 50 { return "battery.75" }
        if level > 25 { return "battery.50" }
        if level > 10 { return "battery.25" }
        return "battery.0"
    }

    private func batteryColor(for level: Int) -> Color {
        if level > 50 { return .green }
        if level > 20 { return .orange }
        return .red
    }

    private func formatLastSeen(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct SignalStrengthIndicator: View {
    let rssi: Int

    var bars: Int {
        if rssi >= -50 { return 4 }
        if rssi >= -60 { return 3 }
        if rssi >= -70 { return 2 }
        return 1
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(i < bars ? Color.bluetoothGradientStart : Color.gray.opacity(0.3))
                    .frame(width: 4, height: CGFloat(6 + i * 3))
            }
        }
    }
}

#Preview {
    BluetoothDetailView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
