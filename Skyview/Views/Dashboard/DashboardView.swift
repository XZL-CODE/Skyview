//
//  DashboardView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var manager = SystemInfoManager()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 顶部系统概览栏
                SystemOverviewBar(systemInfo: manager.systemInfo)

                // 卡片网格
                LazyVGrid(columns: columns, spacing: 16) {
                    CPUCardView(
                        cpuInfo: manager.cpuInfo,
                        history: manager.cpuHistory
                    )

                    MemoryCardView(
                        memoryInfo: manager.memoryInfo,
                        history: manager.memoryHistory
                    )

                    StorageCardView(
                        storageInfo: manager.storageInfo
                    )

                    NetworkCardView(
                        networkInfo: manager.networkInfo,
                        downloadHistory: manager.downloadHistory,
                        uploadHistory: manager.uploadHistory
                    )

                    BatteryCardView(
                        batteryInfo: manager.batteryInfo
                    )

                    SystemCardView(
                        systemInfo: manager.systemInfo
                    )
                }
            }
            .padding(20)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct SystemOverviewBar: View {
    let systemInfo: SystemInfo

    var body: some View {
        HStack(spacing: 20) {
            // 设备名称
            HStack(spacing: 8) {
                Image(systemName: "laptopcomputer")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)

                Text(systemInfo.hostname)
                    .font(.headline)
            }

            Divider()
                .frame(height: 20)

            // 系统版本
            HStack(spacing: 8) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Text(formatOSVersion(systemInfo.osVersion))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider()
                .frame(height: 20)

            // 运行时间
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Text("运行: \(systemInfo.uptime.formatUptime())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 刷新指示器
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)

                Text("实时监控中")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }

    private func formatOSVersion(_ version: String) -> String {
        if let range = version.range(of: "Version ") {
            let afterVersion = version[range.upperBound...]
            if let endRange = afterVersion.firstIndex(of: " ") {
                return "macOS " + String(afterVersion[..<endRange])
            }
        }

        // 尝试提取更简洁的版本信息
        if version.contains("15.") {
            return "macOS Sequoia"
        } else if version.contains("14.") {
            return "macOS Sonoma"
        } else if version.contains("13.") {
            return "macOS Ventura"
        }

        return version
    }
}

#Preview {
    DashboardView()
        .frame(width: 600, height: 800)
}
