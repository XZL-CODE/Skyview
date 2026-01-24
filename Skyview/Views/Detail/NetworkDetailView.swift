//
//  NetworkDetailView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct NetworkDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "网络监控",
                    subtitle: manager.networkInfo.activeInterface,
                    icon: "network",
                    gradient: [.networkGradientStart, .networkGradientEnd]
                )

                // 实时速度
                HStack(spacing: 20) {
                    // 下载
                    SpeedCard(
                        title: "下载速度",
                        speed: manager.networkInfo.downloadSpeed,
                        icon: "arrow.down.circle.fill",
                        color: .green,
                        total: manager.networkInfo.bytesReceived,
                        totalLabel: "总接收"
                    )

                    // 上传
                    SpeedCard(
                        title: "上传速度",
                        speed: manager.networkInfo.uploadSpeed,
                        icon: "arrow.up.circle.fill",
                        color: .blue,
                        total: manager.networkInfo.bytesSent,
                        totalLabel: "总发送"
                    )
                }

                // 流量图表
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("流量趋势")
                            .font(.headline)

                        Spacer()

                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Circle().fill(Color.green).frame(width: 8, height: 8)
                                Text("下载").font(.caption).foregroundColor(.secondary)
                            }
                            HStack(spacing: 4) {
                                Circle().fill(Color.blue).frame(width: 8, height: 8)
                                Text("上传").font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }

                    ZStack {
                        SparklineChartView(
                            data: manager.downloadHistory,
                            lineColor: .green,
                            height: 100
                        )

                        SparklineChartView(
                            data: manager.uploadHistory,
                            lineColor: .blue,
                            fillGradient: [Color.blue.opacity(0.2), Color.blue.opacity(0)],
                            height: 100
                        )
                    }
                }
                .padding(24)
                .background(Color.cardBackground)
                .cornerRadius(20)

                // 网络信息
                VStack(alignment: .leading, spacing: 16) {
                    Text("连接信息")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        InfoCard(label: "活跃接口", value: manager.networkInfo.activeInterface)
                        InfoCard(label: "IP 地址", value: manager.networkInfo.ipAddress ?? "未获取")
                        InfoCard(label: "总接收", value: ByteFormatter.format(manager.networkInfo.bytesReceived))
                        InfoCard(label: "总发送", value: ByteFormatter.format(manager.networkInfo.bytesSent))
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

struct SpeedCard: View {
    let title: String
    let speed: Double
    let icon: String
    let color: Color
    let total: UInt64
    let totalLabel: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text(ByteFormatter.formatSpeed(speed))
                    .font(.system(size: 32, weight: .bold, design: .rounded))

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider()

            HStack {
                Text(totalLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(ByteFormatter.format(total))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

#Preview {
    NetworkDetailView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
