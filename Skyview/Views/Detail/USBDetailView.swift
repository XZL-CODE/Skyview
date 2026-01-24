//
//  USBDetailView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct USBDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "USB 设备",
                    subtitle: "\(manager.usbDevices.count) 个设备已连接",
                    icon: "cable.connector",
                    gradient: [.usbGradientStart, .usbGradientEnd]
                )

                // USB 设备列表
                if !manager.usbDevices.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(manager.usbDevices) { device in
                            USBDeviceCardView(device: device)
                        }
                    }
                    .padding(20)
                    .background(Color.cardBackground)
                    .cornerRadius(20)
                } else {
                    EmptyStateView(
                        icon: "cable.connector",
                        title: "未检测到 USB 设备",
                        message: "请连接 USB 设备"
                    )
                }

                // USB 统计
                if !manager.usbDevices.isEmpty {
                    USBStatisticsView(devices: manager.usbDevices)
                }
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct USBDeviceCardView: View {
    let device: USBDeviceInfo

    var speedColor: Color {
        if device.speed.contains("3.2") || device.speed.contains("3.1") {
            return .purple
        } else if device.speed.contains("3.0") {
            return .blue
        } else if device.speed.contains("2.0") {
            return .green
        } else {
            return .gray
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(speedColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: "cable.connector")
                    .font(.system(size: 20))
                    .foregroundColor(speedColor)
            }

            // 设备信息
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(device.vendorName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 速度标签
            VStack(alignment: .trailing, spacing: 4) {
                Text(device.speed.replacingOccurrences(of: "USB ", with: ""))
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(speedColor.opacity(0.15))
                    .foregroundColor(speedColor)
                    .cornerRadius(6)

                Text(device.powerFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct USBStatisticsView: View {
    let devices: [USBDeviceInfo]

    var totalPower: Int {
        devices.reduce(0) { $0 + $1.power }
    }

    var usb3Count: Int {
        devices.filter { $0.speed.contains("3.") }.count
    }

    var usb2Count: Int {
        devices.filter { $0.speed.contains("2.0") }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("设备统计")
                .font(.headline)

            HStack(spacing: 16) {
                USBStatCard(
                    label: "总设备数",
                    value: "\(devices.count)",
                    icon: "cable.connector",
                    color: .usbGradientStart
                )

                USBStatCard(
                    label: "USB 3.x",
                    value: "\(usb3Count)",
                    icon: "bolt.fill",
                    color: .purple
                )

                USBStatCard(
                    label: "USB 2.0",
                    value: "\(usb2Count)",
                    icon: "tortoise.fill",
                    color: .green
                )

                USBStatCard(
                    label: "总功耗",
                    value: "\(totalPower) mA",
                    icon: "bolt.circle",
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct USBStatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    USBDetailView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
