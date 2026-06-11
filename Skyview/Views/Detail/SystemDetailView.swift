//
//  SystemDetailView.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct SystemDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "系统信息",
                    subtitle: manager.systemInfo.hostname,
                    icon: "desktopcomputer",
                    gradient: [.systemGradientStart, .systemGradientEnd]
                )

                // 设备信息卡片
                HStack(spacing: 20) {
                    // 设备图标
                    VStack(spacing: 16) {
                        Image(systemName: getDeviceIcon())
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.systemGradientStart, .systemGradientEnd],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        Text(manager.systemInfo.modelName)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(manager.systemInfo.hostname)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.cardBackground)
                    .cornerRadius(20)

                    // 快速信息
                    VStack(spacing: 0) {
                        SystemQuickInfo(
                            icon: "cpu",
                            label: "处理器",
                            value: truncateProcessor(manager.systemInfo.processorName)
                        )
                        Divider().padding(.vertical, 8)
                        SystemQuickInfo(
                            icon: "memorychip",
                            label: "内存",
                            value: ByteFormatter.format(manager.systemInfo.physicalMemory, decimals: 0)
                        )
                        Divider().padding(.vertical, 8)
                        SystemQuickInfo(
                            icon: "number",
                            label: "核心数",
                            value: "\(manager.systemInfo.processorCount) 核心"
                        )
                        Divider().padding(.vertical, 8)
                        SystemQuickInfo(
                            icon: "clock",
                            label: "运行时间",
                            value: manager.systemInfo.uptime.formatUptime()
                        )
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.cardBackground)
                    .cornerRadius(20)
                }

                // 软件信息
                VStack(alignment: .leading, spacing: 16) {
                    Text("软件信息")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        InfoCard(label: "操作系统", value: formatOSName())
                        InfoCard(label: "系统版本", value: formatOSVersion())
                        InfoCard(label: "内核版本", value: manager.systemInfo.kernelVersion)
                        InfoCard(label: "架构", value: getArchitecture())
                    }
                }
                .padding(24)
                .background(Color.cardBackground)
                .cornerRadius(20)

                // 硬件信息
                VStack(alignment: .leading, spacing: 16) {
                    Text("硬件信息")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        InfoCard(label: "型号", value: manager.systemInfo.modelName)
                        InfoCard(label: "处理器", value: truncateProcessor(manager.systemInfo.processorName))
                        InfoCard(label: "CPU 核心", value: "\(manager.systemInfo.processorCount) 核心")
                        InfoCard(label: "物理内存", value: ByteFormatter.format(manager.systemInfo.physicalMemory, decimals: 0))
                    }
                }
                .padding(24)
                .background(Color.cardBackground)
                .cornerRadius(20)

                // 运行时间详情
                UptimeCard(uptime: manager.systemInfo.uptime)
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func getDeviceIcon() -> String {
        let model = manager.systemInfo.modelName.lowercased()
        if model.contains("macbook") {
            return "laptopcomputer"
        } else if model.contains("imac") {
            return "desktopcomputer"
        } else if model.contains("mac mini") {
            return "macmini"
        } else if model.contains("mac pro") {
            return "macpro.gen3"
        } else if model.contains("mac studio") {
            return "macstudio"
        }
        return "desktopcomputer"
    }

    private func truncateProcessor(_ name: String) -> String {
        name.replacingOccurrences(of: "(R)", with: "")
            .replacingOccurrences(of: "(TM)", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    private func formatOSName() -> String {
        let version = manager.systemInfo.osVersion
        if version.contains("15.") || version.contains("Version 15") {
            return "macOS Sequoia"
        } else if version.contains("14.") {
            return "macOS Sonoma"
        } else if version.contains("13.") {
            return "macOS Ventura"
        }
        return "macOS"
    }

    private func formatOSVersion() -> String {
        let version = manager.systemInfo.osVersion
        if let range = version.range(of: "Version ") {
            let afterVersion = version[range.upperBound...]
            if let endRange = afterVersion.firstIndex(of: " ") {
                return String(afterVersion[..<endRange])
            }
            return String(afterVersion)
        }
        return version
    }

    private func getArchitecture() -> String {
        #if arch(arm64)
        return "ARM64 (Apple Silicon)"
        #else
        return "x86_64 (Intel)"
        #endif
    }
}

struct SystemQuickInfo: View {
    let icon: String
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
        }
    }
}

struct UptimeCard: View {
    let uptime: TimeInterval

    var days: Int { Int(uptime) / 86400 }
    var hours: Int { (Int(uptime) % 86400) / 3600 }
    var minutes: Int { (Int(uptime) % 3600) / 60 }
    var seconds: Int { Int(uptime) % 60 }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("运行时间")
                .font(.headline)

            HStack(spacing: 20) {
                UptimeUnit(value: days, label: "天")
                UptimeUnit(value: hours, label: "小时")
                UptimeUnit(value: minutes, label: "分钟")
                UptimeUnit(value: seconds, label: "秒")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct UptimeUnit: View {
    let value: Int
    let label: LocalizedStringKey

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    SystemDetailView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
