//
//  NetworkCardView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct NetworkCardView: View {
    let networkInfo: NetworkInfo
    let downloadHistory: [Double]
    let uploadHistory: [Double]

    private let downloadColor: Color = .green
    private let uploadColor: Color = .blue

    var body: some View {
        CardContainerView(
            title: "网络",
            iconName: "network",
            iconColor: .networkGradientStart
        ) {
            VStack(spacing: 16) {
                // 速度显示
                HStack(spacing: 20) {
                    // 下载速度
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(downloadColor)

                        Text(ByteFormatter.formatSpeed(networkInfo.downloadSpeed))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))

                        Text("下载")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // 上传速度
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(uploadColor)

                        Text(ByteFormatter.formatSpeed(networkInfo.uploadSpeed))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))

                        Text("上传")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)

                // 网络信息
                VStack(spacing: 8) {
                    InfoRowView(
                        label: "接口",
                        value: networkInfo.activeInterface
                    )
                    if let ip = networkInfo.ipAddress {
                        InfoRowView(
                            label: "IP 地址",
                            value: ip
                        )
                    }
                    InfoRowView(
                        label: "总接收",
                        value: ByteFormatter.format(networkInfo.bytesReceived)
                    )
                    InfoRowView(
                        label: "总发送",
                        value: ByteFormatter.format(networkInfo.bytesSent)
                    )
                }

                // 流量图表
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(downloadColor)
                            .frame(width: 8, height: 8)
                        Text("下载")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Circle()
                            .fill(uploadColor)
                            .frame(width: 8, height: 8)
                        Text("上传")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ZStack {
                        SparklineChartView(
                            data: downloadHistory,
                            lineColor: downloadColor,
                            height: 35
                        )

                        SparklineChartView(
                            data: uploadHistory,
                            lineColor: uploadColor,
                            fillGradient: [uploadColor.opacity(0.2), uploadColor.opacity(0.0)],
                            height: 35
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    NetworkCardView(
        networkInfo: NetworkInfo.placeholder,
        downloadHistory: [100, 200, 150, 300, 250, 400, 350, 500, 450, 600],
        uploadHistory: [50, 100, 75, 150, 125, 200, 175, 250, 225, 300]
    )
    .frame(width: 220)
    .padding()
}
