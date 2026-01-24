//
//  ApplicationDetailView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI
import AppKit

struct ApplicationDetailView: View {
    @ObservedObject var manager: SystemInfoManager
    @State private var sortOrder: AppSortOrder = .memory

    var sortedApps: [AppInfo] {
        switch sortOrder {
        case .memory:
            return manager.topApps.sorted { $0.memoryUsage > $1.memoryUsage }
        case .cpu:
            return manager.topApps.sorted { $0.cpuUsage > $1.cpuUsage }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "应用监控",
                    subtitle: "Top \(manager.topApps.count) 内存消耗应用",
                    icon: "app.badge",
                    gradient: [.appGradientStart, .appGradientEnd]
                )

                // 排序选择器
                HStack {
                    Text("排序方式")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Picker("排序", selection: $sortOrder) {
                        Text("内存占用").tag(AppSortOrder.memory)
                        Text("CPU 使用率").tag(AppSortOrder.cpu)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.cardBackground)
                .cornerRadius(12)

                // 应用列表
                VStack(spacing: 0) {
                    // 表头
                    AppHeaderRow()

                    Divider()

                    // 应用行
                    if sortedApps.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "app.dashed")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("暂无运行中的应用")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                    } else {
                        ForEach(Array(sortedApps.enumerated()), id: \.element.id) { index, app in
                            AppRowView(app: app, rank: index + 1, sortOrder: sortOrder)

                            if index < sortedApps.count - 1 {
                                Divider()
                                    .padding(.leading, 76)
                            }
                        }
                    }
                }
                .background(Color.cardBackground)
                .cornerRadius(20)

                // 应用资源概览
                AppResourceSummary(apps: manager.topApps)
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct AppHeaderRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("#")
                .frame(width: 24, alignment: .center)

            Text("应用")
                .frame(width: 44, alignment: .center)

            Text("名称")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("PID")
                .frame(width: 60, alignment: .trailing)

            Text("线程")
                .frame(width: 50, alignment: .trailing)

            Text("CPU")
                .frame(width: 70, alignment: .trailing)

            Text("内存")
                .frame(width: 80, alignment: .trailing)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct AppRowView: View {
    let app: AppInfo
    let rank: Int
    let sortOrder: AppSortOrder

    var rankColor: Color {
        switch rank {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // 排名
            ZStack {
                Circle()
                    .fill(rankColor.opacity(rank <= 3 ? 0.15 : 0.05))
                    .frame(width: 24, height: 24)

                Text("\(rank)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(rank <= 3 ? rankColor : .secondary)
            }

            // 应用图标
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)
            } else {
                Image(systemName: "app.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
            }

            // 应用名称
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if let bundleId = app.bundleIdentifier {
                    Text(bundleId)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // PID
            Text("\(app.pid)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)

            // 线程数
            Text("\(app.threads)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)

            // CPU
            HStack(spacing: 4) {
                if sortOrder == .cpu {
                    AppCPUBar(usage: app.cpuUsage)
                }
                Text(app.cpuFormatted)
                    .font(.system(size: 12, weight: sortOrder == .cpu ? .semibold : .regular, design: .rounded))
                    .foregroundColor(sortOrder == .cpu ? .appGradientStart : .secondary)
            }
            .frame(width: 70, alignment: .trailing)

            // 内存
            Text(app.memoryFormatted)
                .font(.system(size: 12, weight: sortOrder == .memory ? .semibold : .regular, design: .rounded))
                .foregroundColor(sortOrder == .memory ? .appGradientStart : .secondary)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(rank <= 3 ? rankColor.opacity(0.03) : Color.clear)
    }
}

struct AppCPUBar: View {
    let usage: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.2))

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appGradientStart)
                    .frame(width: geometry.size.width * min(usage / 100, 1.0))
            }
        }
        .frame(width: 30, height: 6)
    }
}

struct AppResourceSummary: View {
    let apps: [AppInfo]

    var totalCPU: Double {
        apps.reduce(0) { $0 + $1.cpuUsage }
    }

    var totalMemory: UInt64 {
        apps.reduce(0) { $0 + $1.memoryUsage }
    }

    var totalThreads: Int32 {
        apps.reduce(0) { $0 + $1.threads }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("应用资源占用统计")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("\(apps.count)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.appGradientStart)

                    Text("运行应用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)

                VStack(spacing: 8) {
                    Text(String(format: "%.1f%%", totalCPU))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.cpuGradientStart)

                    Text("CPU 总占用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)

                VStack(spacing: 8) {
                    Text(ByteFormatter.format(totalMemory))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.memoryGradientStart)

                    Text("内存总占用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)

                VStack(spacing: 8) {
                    Text("\(totalThreads)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)

                    Text("总线程数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

#Preview {
    ApplicationDetailView(manager: SystemInfoManager())
        .frame(width: 700, height: 700)
}
