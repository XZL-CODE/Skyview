//
//  CPUDetailView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct CPUDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "CPU 监控",
                    subtitle: manager.cpuInfo.brand,
                    icon: "cpu",
                    gradient: [.cpuGradientStart, .cpuGradientEnd]
                )

                // 主要指标
                HStack(spacing: 20) {
                    // 大仪表盘
                    LargeGaugeView(
                        value: manager.cpuInfo.usage,
                        title: "总使用率",
                        gradient: [.cpuGradientStart, .cpuGradientEnd]
                    )

                    // 详细分解
                    VStack(spacing: 16) {
                        UsageBreakdownRow(
                            label: "用户",
                            value: manager.cpuInfo.userUsage,
                            color: .blue
                        )
                        UsageBreakdownRow(
                            label: "系统",
                            value: manager.cpuInfo.systemUsage,
                            color: .orange
                        )
                        UsageBreakdownRow(
                            label: "Nice",
                            value: manager.cpuInfo.niceUsage,
                            color: .purple
                        )
                        UsageBreakdownRow(
                            label: "空闲",
                            value: manager.cpuInfo.idleUsage,
                            color: .gray
                        )

                        Divider()

                        // 系统负载
                        VStack(alignment: .leading, spacing: 8) {
                            Text("系统负载")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(manager.cpuInfo.loadAverageFormatted)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(24)
                    .background(Color.cardBackground)
                    .cornerRadius(20)
                }

                // 核心信息卡片 (Apple Silicon 特有)
                if manager.cpuInfo.isAppleSilicon {
                    HStack(spacing: 16) {
                        CoreTypeCard(
                            title: "性能核心",
                            count: manager.cpuInfo.performanceCores,
                            icon: "bolt.fill",
                            color: .orange
                        )
                        CoreTypeCard(
                            title: "能效核心",
                            count: manager.cpuInfo.efficiencyCores,
                            icon: "leaf.fill",
                            color: .green
                        )
                    }
                }

                // 每核心使用率
                if !manager.cpuInfo.perCoreUsage.isEmpty {
                    PerCoreUsageView(
                        usage: manager.cpuInfo.perCoreUsage,
                        performanceCores: manager.cpuInfo.performanceCores,
                        efficiencyCores: manager.cpuInfo.efficiencyCores
                    )
                }

                // 历史图表
                DetailChartCard(
                    title: "CPU 使用率历史",
                    data: manager.cpuHistory,
                    color: .cpuGradientStart,
                    unit: "%"
                )

                // 处理器详情
                VStack(alignment: .leading, spacing: 16) {
                    Text("处理器详情")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        InfoCard(label: "处理器", value: truncateProcessor(manager.cpuInfo.brand))
                        InfoCard(label: "架构", value: manager.cpuInfo.architecture)
                        InfoCard(label: "核心数", value: "\(manager.cpuInfo.coreCount) 核心")
                        InfoCard(label: "型号", value: manager.systemInfo.modelName)
                    }
                }
                .padding(24)
                .background(Color.cardBackground)
                .cornerRadius(20)

                // 缓存信息
                VStack(alignment: .leading, spacing: 16) {
                    Text("缓存信息")
                        .font(.headline)

                    HStack(spacing: 16) {
                        CacheCard(level: "L1", size: manager.cpuInfo.l1CacheFormatted, color: .blue)
                        CacheCard(level: "L2", size: manager.cpuInfo.l2CacheFormatted, color: .purple)
                        CacheCard(level: "L3", size: manager.cpuInfo.l3CacheFormatted, color: .orange)
                    }
                }
                .padding(24)
                .background(Color.cardBackground)
                .cornerRadius(20)
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func truncateProcessor(_ name: String) -> String {
        name.replacingOccurrences(of: "(R)", with: "")
            .replacingOccurrences(of: "(TM)", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

struct CoreTypeCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("\(count)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text("核心")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

struct PerCoreUsageView: View {
    let usage: [Double]
    let performanceCores: Int
    let efficiencyCores: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("每核心使用率")
                .font(.headline)

            // 性能核心
            if performanceCores > 0 && usage.count >= performanceCores {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.orange)
                        Text("性能核心")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: min(performanceCores, 6)), spacing: 8) {
                        ForEach(0..<performanceCores, id: \.self) { index in
                            CoreUsageBar(
                                coreNumber: index,
                                usage: index < usage.count ? usage[index] : 0,
                                color: .orange
                            )
                        }
                    }
                }
            }

            // 能效核心
            if efficiencyCores > 0 && usage.count >= performanceCores + efficiencyCores {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                        Text("能效核心")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: min(efficiencyCores, 6)), spacing: 8) {
                        ForEach(0..<efficiencyCores, id: \.self) { index in
                            CoreUsageBar(
                                coreNumber: performanceCores + index,
                                usage: performanceCores + index < usage.count ? usage[performanceCores + index] : 0,
                                color: .green
                            )
                        }
                    }
                }
            }

            // 如果不是 Apple Silicon，显示所有核心
            if efficiencyCores == 0 {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: min(usage.count, 8)), spacing: 8) {
                    ForEach(0..<usage.count, id: \.self) { index in
                        CoreUsageBar(
                            coreNumber: index,
                            usage: usage[index],
                            color: .cpuGradientStart
                        )
                    }
                }
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct CoreUsageBar: View {
    let coreNumber: Int
    let usage: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 50)

                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(height: 50 * min(usage / 100, 1.0))
            }
            .frame(height: 50)

            Text("\(coreNumber)")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)

            Text(String(format: "%.0f%%", usage))
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

struct CacheCard: View {
    let level: String
    let size: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(level)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)

            Text(size)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct LargeGaugeView: View {
    let value: Double
    let title: String
    let gradient: [Color]

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 背景
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 20)

                // 进度
                Circle()
                    .trim(from: 0, to: min(value / 100, 1.0))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: gradient + [gradient[0]]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: value)

                // 数值
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", value))
                        .font(.system(size: 48, weight: .bold, design: .rounded))

                    Text("%")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 180, height: 180)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct UsageBreakdownRow: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(String(format: "%.1f%%", value))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
        }
    }
}

struct InfoPill: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
    }
}

struct InfoCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    CPUDetailView(manager: SystemInfoManager())
        .frame(width: 700, height: 900)
}
