//
//  BatteryDetailView.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct BatteryDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var batteryColor: Color {
        if manager.batteryInfo.isCharging { return .green }
        if manager.batteryInfo.level > 50 { return .batteryGradientStart }
        if manager.batteryInfo.level > 20 { return .orange }
        return .red
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "电池状态",
                    subtitle: manager.batteryInfo.statusText,
                    icon: manager.batteryInfo.isCharging ? "battery.100.bolt" : "battery.100",
                    gradient: [.batteryGradientStart, .batteryGradientEnd]
                )

                if manager.batteryInfo.hasBattery {
                    // 主要显示
                    HStack(spacing: 20) {
                        // 电池可视化
                        BatteryVisualization(
                            level: manager.batteryInfo.level,
                            isCharging: manager.batteryInfo.isCharging,
                            color: batteryColor
                        )

                        // 详细信息
                        VStack(spacing: 16) {
                            BatteryInfoRow(
                                label: "当前电量",
                                value: String(format: "%.0f%%", manager.batteryInfo.level),
                                color: batteryColor
                            )

                            if let health = manager.batteryInfo.health {
                                BatteryInfoRow(
                                    label: "电池健康",
                                    value: String(format: "%.1f%%", health),
                                    color: health > 80 ? .green : .orange
                                )
                            }

                            if let cycleCount = manager.batteryInfo.cycleCount {
                                BatteryInfoRow(
                                    label: "循环次数",
                                    value: "\(cycleCount) 次",
                                    color: .secondary
                                )
                            }

                            BatteryInfoRow(
                                label: "电源状态",
                                value: manager.batteryInfo.isPluggedIn ? "已连接电源" : "使用电池",
                                color: manager.batteryInfo.isPluggedIn ? .green : .orange
                            )

                            if manager.batteryInfo.isCharging {
                                BatteryInfoRow(
                                    label: "充电状态",
                                    value: "正在充电",
                                    color: .green
                                )
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Color.cardBackground)
                        .cornerRadius(20)
                    }

                    // 电池健康提示
                    if let health = manager.batteryInfo.health {
                        BatteryHealthCard(health: health, cycleCount: manager.batteryInfo.cycleCount)
                    }

                    // 电池信息
                    VStack(alignment: .leading, spacing: 16) {
                        Text("电池信息")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            InfoCard(label: "电池类型", value: "锂离子电池")
                            InfoCard(label: "状态", value: manager.batteryInfo.statusText)
                            if let cycleCount = manager.batteryInfo.cycleCount {
                                InfoCard(label: "循环次数", value: "\(cycleCount) 次")
                            }
                            if let health = manager.batteryInfo.health {
                                InfoCard(label: "健康度", value: String(format: "%.1f%%", health))
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.cardBackground)
                    .cornerRadius(20)
                } else {
                    // 无电池
                    NoBatteryView()
                }
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct BatteryVisualization: View {
    let level: Double
    let isCharging: Bool
    let color: Color

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 电池外框
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 120, height: 200)

                // 电池帽
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 12)
                    .offset(y: -106)

                // 电量
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 108, height: max(188 * (level / 100), 0))
                }
                .frame(width: 120, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // 充电图标
                if isCharging {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }

                // 百分比
                Text(String(format: "%.0f%%", level))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(level > 50 ? .white : .primary)
            }

            Text(isCharging ? "充电中" : "电池供电")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct BatteryInfoRow: View {
    let label: LocalizedStringKey
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

struct BatteryHealthCard: View {
    let health: Double
    let cycleCount: Int?

    var healthStatus: (text: String, color: Color, icon: String) {
        if health >= 90 {
            return ("电池健康状况良好", .green, "checkmark.circle.fill")
        } else if health >= 80 {
            return ("电池健康状况正常", .blue, "info.circle.fill")
        } else if health >= 60 {
            return ("电池性能有所下降", .orange, "exclamationmark.circle.fill")
        } else {
            return ("建议更换电池", .red, "exclamationmark.triangle.fill")
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: healthStatus.icon)
                .font(.system(size: 32))
                .foregroundColor(healthStatus.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(healthStatus.text)
                    .font(.headline)

                if let cycles = cycleCount {
                    Text("已完成 \(cycles) 次充电循环")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "%.1f%%", health))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(healthStatus.color)

                Text("健康度")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(healthStatus.color.opacity(0.1))
        .cornerRadius(16)
    }
}

struct NoBatteryView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("已连接电源")
                .font(.title2)
                .fontWeight(.semibold)

            Text("此设备没有内置电池，始终使用交流电源供电")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

#Preview {
    BatteryDetailView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
