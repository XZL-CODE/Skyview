//
//  StorageDetailView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct StorageDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "存储空间",
                    subtitle: manager.storageInfo.volumeName,
                    icon: "internaldrive",
                    gradient: [.storageGradientStart, .storageGradientEnd]
                )

                // 主要指标
                HStack(spacing: 20) {
                    // 大仪表盘
                    LargeGaugeView(
                        value: manager.storageInfo.usagePercentage,
                        title: "已使用空间",
                        gradient: [.storageGradientStart, .storageGradientEnd]
                    )

                    // 详细信息
                    VStack(spacing: 20) {
                        StorageInfoRow(
                            label: "总容量",
                            value: ByteFormatter.format(manager.storageInfo.total),
                            icon: "internaldrive.fill",
                            color: .gray
                        )

                        StorageInfoRow(
                            label: "已使用",
                            value: ByteFormatter.format(manager.storageInfo.used),
                            icon: "square.fill",
                            color: .storageGradientStart
                        )

                        StorageInfoRow(
                            label: "可用空间",
                            value: ByteFormatter.format(manager.storageInfo.free),
                            icon: "square",
                            color: .green
                        )
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.cardBackground)
                    .cornerRadius(20)
                }

                // 存储使用可视化
                StorageVisualizationView(storageInfo: manager.storageInfo)

                // 磁盘信息
                VStack(alignment: .leading, spacing: 16) {
                    Text("磁盘信息")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        InfoCard(label: "卷名", value: manager.storageInfo.volumeName)
                        InfoCard(label: "文件系统", value: "APFS")
                        InfoCard(label: "已使用百分比", value: String(format: "%.1f%%", manager.storageInfo.usagePercentage))
                        InfoCard(label: "状态", value: manager.storageInfo.usagePercentage > 90 ? "空间不足" : "正常")
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
}

struct StorageInfoRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }

            Spacer()
        }
    }
}

struct StorageVisualizationView: View {
    let storageInfo: StorageInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("存储使用")
                .font(.headline)

            // 大型进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.15))

                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.storageGradientStart, .storageGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (storageInfo.usagePercentage / 100))
                        .animation(.easeInOut, value: storageInfo.usagePercentage)
                }
            }
            .frame(height: 40)

            // 标签
            HStack {
                VStack(alignment: .leading) {
                    Text("已使用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ByteFormatter.format(storageInfo.used))
                        .font(.headline)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("可用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ByteFormatter.format(storageInfo.free))
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }

            // 空间警告
            if storageInfo.usagePercentage > 80 {
                HStack {
                    Image(systemName: storageInfo.usagePercentage > 90 ? "exclamationmark.triangle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(storageInfo.usagePercentage > 90 ? .red : .orange)

                    Text(storageInfo.usagePercentage > 90 ? "磁盘空间严重不足，请清理文件" : "磁盘空间不足，建议清理文件")
                        .font(.subheadline)
                        .foregroundColor(storageInfo.usagePercentage > 90 ? .red : .orange)

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(storageInfo.usagePercentage > 90 ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
                )
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

#Preview {
    StorageDetailView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
