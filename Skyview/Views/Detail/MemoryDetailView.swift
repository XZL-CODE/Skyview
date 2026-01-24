//
//  MemoryDetailView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct MemoryDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "内存监控",
                    subtitle: ByteFormatter.format(manager.memoryInfo.total, decimals: 0) + " 总内存",
                    icon: "memorychip",
                    gradient: [.memoryGradientStart, .memoryGradientEnd]
                )

                // 主要指标
                HStack(spacing: 20) {
                    // 大仪表盘
                    LargeGaugeView(
                        value: manager.memoryInfo.usagePercentage,
                        title: "内存使用率",
                        gradient: [.memoryGradientStart, .memoryGradientEnd]
                    )

                    // 内存分类
                    VStack(spacing: 0) {
                        MemoryTypeRow(
                            label: "已使用",
                            value: manager.memoryInfo.used,
                            total: manager.memoryInfo.total,
                            color: .memoryGradientStart
                        )
                        Divider().padding(.vertical, 8)
                        MemoryTypeRow(
                            label: "可用",
                            value: manager.memoryInfo.free,
                            total: manager.memoryInfo.total,
                            color: .gray
                        )
                        Divider().padding(.vertical, 8)
                        MemoryTypeRow(
                            label: "活跃",
                            value: manager.memoryInfo.active,
                            total: manager.memoryInfo.total,
                            color: .green
                        )
                        Divider().padding(.vertical, 8)
                        MemoryTypeRow(
                            label: "非活跃",
                            value: manager.memoryInfo.inactive,
                            total: manager.memoryInfo.total,
                            color: .blue
                        )
                        Divider().padding(.vertical, 8)
                        MemoryTypeRow(
                            label: "已联动",
                            value: manager.memoryInfo.wired,
                            total: manager.memoryInfo.total,
                            color: .orange
                        )
                        Divider().padding(.vertical, 8)
                        MemoryTypeRow(
                            label: "已压缩",
                            value: manager.memoryInfo.compressed,
                            total: manager.memoryInfo.total,
                            color: .purple
                        )
                    }
                    .padding(24)
                    .background(Color.cardBackground)
                    .cornerRadius(20)
                }

                // 内存组成可视化
                MemoryCompositionView(memoryInfo: manager.memoryInfo)

                // 历史图表
                DetailChartCard(
                    title: "内存使用率历史",
                    data: manager.memoryHistory,
                    color: .memoryGradientStart,
                    unit: "%"
                )
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct MemoryTypeRow: View {
    let label: String
    let value: UInt64
    let total: UInt64
    let color: Color

    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total) * 100
    }

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(ByteFormatter.format(value))
                .font(.system(size: 14, weight: .semibold, design: .rounded))

            Text(String(format: "(%.1f%%)", percentage))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
    }
}

struct MemoryCompositionView: View {
    let memoryInfo: MemoryInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("内存组成")
                .font(.headline)

            GeometryReader { geometry in
                let total = Double(memoryInfo.total)
                let width = geometry.size.width

                HStack(spacing: 2) {
                    // 活跃
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: width * Double(memoryInfo.active) / total)

                    // 非活跃
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue)
                        .frame(width: width * Double(memoryInfo.inactive) / total)

                    // 已联动
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.orange)
                        .frame(width: width * Double(memoryInfo.wired) / total)

                    // 已压缩
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.purple)
                        .frame(width: width * Double(memoryInfo.compressed) / total)

                    // 空闲
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: max(width * Double(memoryInfo.free) / total, 0))
                }
            }
            .frame(height: 24)

            // 图例
            HStack(spacing: 16) {
                LegendItem(color: .green, label: "活跃")
                LegendItem(color: .blue, label: "非活跃")
                LegendItem(color: .orange, label: "已联动")
                LegendItem(color: .purple, label: "已压缩")
                LegendItem(color: .gray.opacity(0.3), label: "空闲")
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MemoryDetailView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
