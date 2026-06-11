//
//  DisplayDetailView.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct DisplayDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "显示器监控",
                    subtitle: "\(manager.displayInfo.count) 个显示器已连接",
                    icon: "display",
                    gradient: [.displayGradientStart, .displayGradientEnd]
                )

                // 显示器列表
                ForEach(manager.displayInfo) { display in
                    DisplayCardView(display: display)
                }

                if manager.displayInfo.isEmpty {
                    EmptyStateView(
                        icon: "display",
                        title: "未检测到显示器",
                        message: "无法获取显示器信息"
                    )
                }
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct DisplayCardView: View {
    let display: DisplayInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 显示器名称和主显示器标记
            HStack {
                Image(systemName: display.isPrimary ? "display" : "rectangle.on.rectangle")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.displayGradientStart, .displayGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(display.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                if display.isPrimary {
                    TagView(text: "主显示器", color: .blue)
                }

                if display.scaleFactor > 1 {
                    TagView(text: "Retina", color: .purple)
                }
            }

            // 分辨率可视化
            HStack(spacing: 20) {
                // 显示器图形
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 75)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.displayGradientStart.opacity(0.3), .displayGradientEnd.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 65)

                    VStack(spacing: 2) {
                        Text("\(display.width)×\(display.height)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))

                        Text("\(display.refreshRate)Hz")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }

                // 分辨率详情
                VStack(alignment: .leading, spacing: 8) {
                    DisplayInfoRow(label: "逻辑分辨率", value: display.resolution)
                    DisplayInfoRow(label: "原生分辨率", value: display.nativeResolution)
                    DisplayInfoRow(label: "刷新率", value: "\(display.refreshRate) Hz")
                }

                Spacer()
            }

            Divider()

            // 详细信息
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                DisplayStatCard(label: "缩放比例", value: String(format: "%.0fx", display.scaleFactor))
                DisplayStatCard(label: "色彩空间", value: display.colorSpace)
                DisplayStatCard(label: "色深", value: "\(display.bitsPerPixel) bit")
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct DisplayInfoRow: View {
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
        }
    }
}

struct DisplayStatCard: View {
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    DisplayDetailView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
