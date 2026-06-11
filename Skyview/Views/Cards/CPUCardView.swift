//
//  CPUCardView.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct CPUCardView: View {
    let cpuInfo: CPUInfo
    let history: [Double]

    private let gradientColors: [Color] = [.cpuGradientStart, .cpuGradientEnd]

    var body: some View {
        CardContainerView(
            title: "CPU",
            iconName: "cpu",
            iconColor: .cpuGradientStart
        ) {
            VStack(spacing: 16) {
                // 圆形进度条
                CircularProgressView(
                    progress: cpuInfo.usage,
                    lineWidth: 10,
                    gradientColors: gradientColors,
                    size: 90
                )

                // 详细信息
                VStack(spacing: 8) {
                    InfoRowView(
                        label: "用户",
                        value: ByteFormatter.formatPercentage(cpuInfo.userUsage)
                    )
                    InfoRowView(
                        label: "系统",
                        value: ByteFormatter.formatPercentage(cpuInfo.systemUsage)
                    )
                    InfoRowView(
                        label: "核心数",
                        value: "\(cpuInfo.coreCount)"
                    )
                }

                // 历史图表
                VStack(alignment: .leading, spacing: 4) {
                    Text("使用率趋势")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    SparklineChartView(
                        data: history,
                        lineColor: .cpuGradientStart,
                        height: 35
                    )
                }
            }
        }
    }
}

#Preview {
    CPUCardView(
        cpuInfo: CPUInfo.placeholder,
        history: [20, 25, 30, 28, 35, 40, 38, 45, 50, 48]
    )
    .frame(width: 220)
    .padding()
}
