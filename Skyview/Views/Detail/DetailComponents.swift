//
//  DetailComponents.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct DetailHeaderView: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]

    var body: some View {
        HStack(spacing: 16) {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }

            // 文字
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [gradient[0].opacity(0.1), gradient[1].opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct DetailChartCard: View {
    let title: String
    let data: [Double]
    let color: Color
    let unit: String

    var currentValue: String {
        if let last = data.last {
            return String(format: "%.1f%@", last, unit)
        }
        return "--"
    }

    var maxValue: String {
        if let max = data.max() {
            return String(format: "%.1f%@", max, unit)
        }
        return "--"
    }

    var minValue: String {
        if let min = data.min() {
            return String(format: "%.1f%@", min, unit)
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
                    StatPill(label: "当前", value: currentValue, color: color)
                    StatPill(label: "最高", value: maxValue, color: .red)
                    StatPill(label: "最低", value: minValue, color: .green)
                }
            }

            SparklineChartView(
                data: data,
                lineColor: color,
                height: 100
            )
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct StatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(color)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 20) {
        DetailHeaderView(
            title: "CPU 监控",
            subtitle: "Apple M1 Pro",
            icon: "cpu",
            gradient: [.cpuGradientStart, .cpuGradientEnd]
        )

        DetailChartCard(
            title: "CPU 使用率历史",
            data: [20, 25, 30, 28, 35, 40, 38, 45, 50, 48],
            color: .cpuGradientStart,
            unit: "%"
        )
    }
    .padding()
    .frame(width: 500)
}
