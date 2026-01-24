//
//  StorageCardView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct StorageCardView: View {
    let storageInfo: StorageInfo

    private let gradientColors: [Color] = [.storageGradientStart, .storageGradientEnd]

    var body: some View {
        CardContainerView(
            title: "存储",
            iconName: "internaldrive",
            iconColor: .storageGradientStart
        ) {
            VStack(spacing: 16) {
                // 圆形进度条
                CircularProgressView(
                    progress: storageInfo.usagePercentage,
                    lineWidth: 10,
                    gradientColors: gradientColors,
                    size: 90
                )

                // 存储条
                VStack(spacing: 8) {
                    // 可视化存储使用情况
                    GeometryReader { geometry in
                        let usedWidth = geometry.size.width * (storageInfo.usagePercentage / 100)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))

                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: gradientColors,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: usedWidth)
                        }
                    }
                    .frame(height: 12)

                    // 卷名
                    Text(storageInfo.volumeName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // 详细信息
                VStack(spacing: 8) {
                    InfoRowView(
                        label: "已使用",
                        value: ByteFormatter.format(storageInfo.used)
                    )
                    InfoRowView(
                        label: "可用",
                        value: ByteFormatter.format(storageInfo.free),
                        valueColor: .green
                    )
                    InfoRowView(
                        label: "总容量",
                        value: ByteFormatter.format(storageInfo.total)
                    )
                }
            }
        }
    }
}

#Preview {
    StorageCardView(storageInfo: StorageInfo.placeholder)
        .frame(width: 220)
        .padding()
}
