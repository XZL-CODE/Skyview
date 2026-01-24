//
//  DiskIODetailView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct DiskIODetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "磁盘 I/O 监控",
                    subtitle: "实时读写速度监控",
                    icon: "arrow.up.arrow.down.circle",
                    gradient: [.diskIOGradientStart, .diskIOGradientEnd]
                )

                // 主要指标
                HStack(spacing: 20) {
                    // 读取速度
                    DiskIOGaugeCard(
                        title: "读取速度",
                        value: manager.diskIOInfo.readSpeedFormatted,
                        icon: "arrow.down.circle.fill",
                        color: .green
                    )

                    // 写入速度
                    DiskIOGaugeCard(
                        title: "写入速度",
                        value: manager.diskIOInfo.writeSpeedFormatted,
                        icon: "arrow.up.circle.fill",
                        color: .blue
                    )
                }

                // 读取历史图表
                DiskIOChartCard(
                    title: "读取速度历史",
                    data: manager.diskReadHistory,
                    color: .green
                )

                // 写入历史图表
                DiskIOChartCard(
                    title: "写入速度历史",
                    data: manager.diskWriteHistory,
                    color: .blue
                )

                // 累计统计
                DiskIOStatsView(diskIO: manager.diskIOInfo)
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct DiskIOGaugeCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }

            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct DiskIOChartCard: View {
    let title: String
    let data: [Double]
    let color: Color

    var currentValue: String {
        if let last = data.last {
            return ByteFormatter.formatSpeed(last)
        }
        return "--"
    }

    var maxValue: String {
        if let max = data.max(), max > 0 {
            return ByteFormatter.formatSpeed(max)
        }
        return "--"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                HStack(spacing: 16) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(currentValue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(color)
                        Text("当前")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(maxValue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                        Text("峰值")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            SparklineChartView(
                data: data,
                lineColor: color,
                height: 80
            )
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct DiskIOStatsView: View {
    let diskIO: DiskIOInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("累计统计")
                .font(.headline)

            HStack(spacing: 16) {
                DiskIOStatItem(
                    label: "总读取",
                    value: diskIO.totalBytesReadFormatted,
                    icon: "arrow.down.doc.fill",
                    color: .green
                )

                DiskIOStatItem(
                    label: "总写入",
                    value: diskIO.totalBytesWrittenFormatted,
                    icon: "arrow.up.doc.fill",
                    color: .blue
                )

                DiskIOStatItem(
                    label: "读取操作",
                    value: formatOps(diskIO.readOps),
                    icon: "doc.text",
                    color: .green
                )

                DiskIOStatItem(
                    label: "写入操作",
                    value: formatOps(diskIO.writeOps),
                    icon: "doc.text.fill",
                    color: .blue
                )
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }

    private func formatOps(_ ops: UInt64) -> String {
        if ops >= 1_000_000 {
            return String(format: "%.1fM", Double(ops) / 1_000_000)
        } else if ops >= 1_000 {
            return String(format: "%.1fK", Double(ops) / 1_000)
        }
        return "\(ops)"
    }
}

struct DiskIOStatItem: View {
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
                .font(.system(size: 16, weight: .bold, design: .rounded))

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
    DiskIODetailView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
