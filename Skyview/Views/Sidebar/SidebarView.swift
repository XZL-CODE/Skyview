//
//  SidebarView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case overview = "总览"
    case cpu = "CPU"
    case memory = "内存"
    case gpu = "GPU"
    case storage = "存储"
    case diskIO = "磁盘I/O"
    case network = "网络"
    case application = "应用"
    case process = "进程"
    case display = "显示器"
    case audio = "音频"
    case usb = "USB"
    case bluetooth = "蓝牙"
    case battery = "电池"
    case system = "系统"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .overview: return "square.grid.2x2"
        case .cpu: return "cpu"
        case .memory: return "memorychip"
        case .gpu: return "rectangle.3.group"
        case .storage: return "internaldrive"
        case .diskIO: return "arrow.up.arrow.down.circle"
        case .network: return "network"
        case .application: return "app.badge"
        case .process: return "list.bullet.rectangle"
        case .display: return "display"
        case .audio: return "speaker.wave.3"
        case .usb: return "cable.connector"
        case .bluetooth: return "wave.3.right"
        case .battery: return "battery.100"
        case .system: return "desktopcomputer"
        }
    }

    var gradient: [Color] {
        switch self {
        case .overview: return [.purple, .blue]
        case .cpu: return [.cpuGradientStart, .cpuGradientEnd]
        case .memory: return [.memoryGradientStart, .memoryGradientEnd]
        case .gpu: return [.gpuGradientStart, .gpuGradientEnd]
        case .storage: return [.storageGradientStart, .storageGradientEnd]
        case .diskIO: return [.diskIOGradientStart, .diskIOGradientEnd]
        case .network: return [.networkGradientStart, .networkGradientEnd]
        case .application: return [.appGradientStart, .appGradientEnd]
        case .process: return [.processGradientStart, .processGradientEnd]
        case .display: return [.displayGradientStart, .displayGradientEnd]
        case .audio: return [.audioGradientStart, .audioGradientEnd]
        case .usb: return [.usbGradientStart, .usbGradientEnd]
        case .bluetooth: return [.bluetoothGradientStart, .bluetoothGradientEnd]
        case .battery: return [.batteryGradientStart, .batteryGradientEnd]
        case .system: return [.systemGradientStart, .systemGradientEnd]
        }
    }
}

struct SidebarView: View {
    @Binding var selection: NavigationItem
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        VStack(spacing: 0) {
            // Logo 区域
            VStack(spacing: 8) {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("系统监控")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 20)

            Divider()
                .padding(.horizontal, 16)

            // 导航项目
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(NavigationItem.allCases) { item in
                        SidebarItemView(
                            item: item,
                            isSelected: selection == item,
                            manager: manager
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selection = item
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
            }

            Spacer()

            // 底部状态
            VStack(spacing: 8) {
                Divider()
                    .padding(.horizontal, 16)

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .shadow(color: .green.opacity(0.5), radius: 3)

                    Text("监控中")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 16)
            }
        }
        .frame(width: 200)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SidebarItemView: View {
    let item: NavigationItem
    let isSelected: Bool
    @ObservedObject var manager: SystemInfoManager
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            isSelected ?
                            LinearGradient(colors: item.gradient, startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: item.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .white : .secondary)
                }

                // 标题和数值
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.rawValue)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .primary : .secondary)

                    // 实时数值预览
                    Text(getQuickValue())
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 选中指示器
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(colors: item.gradient, startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 4, height: 24)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.gray.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private func getQuickValue() -> String {
        switch item {
        case .overview:
            return "全部信息"
        case .cpu:
            return String(format: "%.1f%%", manager.cpuInfo.usage)
        case .memory:
            return String(format: "%.1f%%", manager.memoryInfo.usagePercentage)
        case .gpu:
            return manager.gpuInfo.first?.name ?? "未检测"
        case .storage:
            return String(format: "%.1f%%", manager.storageInfo.usagePercentage)
        case .diskIO:
            return "↓\(manager.diskIOInfo.readSpeedFormatted)"
        case .network:
            return "↓\(ByteFormatter.formatSpeed(manager.networkInfo.downloadSpeed))"
        case .application:
            return "\(manager.topApps.count) 应用"
        case .process:
            return "\(manager.topProcesses.count) 进程"
        case .display:
            return "\(manager.displayInfo.count) 显示器"
        case .audio:
            return "\(manager.audioDevices.filter { $0.deviceType == .output }.count) 输出"
        case .usb:
            return "\(manager.usbDevices.count) 设备"
        case .bluetooth:
            let connected = manager.bluetoothDevices.filter { $0.isConnected }.count
            return "\(connected) 已连接"
        case .battery:
            return manager.batteryInfo.hasBattery ? String(format: "%.0f%%", manager.batteryInfo.level) : "无电池"
        case .system:
            return manager.systemInfo.uptime.formatUptime()
        }
    }
}
