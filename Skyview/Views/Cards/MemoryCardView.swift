//
//  MemoryCardView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct MemoryCardView: View {
    let memoryInfo: MemoryInfo
    let history: [Double]

    private let gradientColors: [Color] = [.memoryGradientStart, .memoryGradientEnd]

    var body: some View {
        CardContainerView(
            title: "内存",
            iconName: "memorychip",
            iconColor: .memoryGradientStart
        ) {
            VStack(spacing: 16) {
                // 圆形进度条
                CircularProgressView(
                    progress: memoryInfo.usagePercentage,
                    lineWidth: 10,
                    gradientColors: gradientColors,
                    size: 90
                )

                // 详细信息
                VStack(spacing: 8) {
                    InfoRowView(
                        label: "已使用",
                        value: ByteFormatter.format(memoryInfo.used)
                    )
                    InfoRowView(
                        label: "可用",
                        value: ByteFormatter.format(memoryInfo.free)
                    )
                    InfoRowView(
                        label: "总计",
                        value: ByteFormatter.format(memoryInfo.total)
                    )
                }

                // 内存分类
                VStack(spacing: 4) {
                    MemoryBarView(
                        label: "活跃",
                        value: memoryInfo.active,
                        total: memoryInfo.total,
                        color: .green
                    )
                    MemoryBarView(
                        label: "已联动",
                        value: memoryInfo.wired,
                        total: memoryInfo.total,
                        color: .orange
                    )
                    MemoryBarView(
                        label: "已压缩",
                        value: memoryInfo.compressed,
                        total: memoryInfo.total,
                        color: .purple
                    )
                }

                // 历史图表
                VStack(alignment: .leading, spacing: 4) {
                    Text("使用率趋势")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    SparklineChartView(
                        data: history,
                        lineColor: .memoryGradientStart,
                        height: 35
                    )
                }
            }
        }
    }
}

struct MemoryBarView: View {
    let label: String
    let value: UInt64
    let total: UInt64
    let color: Color

    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 6)

            Text(ByteFormatter.format(value, decimals: 0))
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 45, alignment: .trailing)
        }
    }
}

#Preview {
    MemoryCardView(
        memoryInfo: MemoryInfo.placeholder,
        history: [60, 65, 70, 68, 72, 75, 73, 78, 80, 78]
    )
    .frame(width: 220)
    .padding()
}
