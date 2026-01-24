//
//  BatteryCardView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct BatteryCardView: View {
    let batteryInfo: BatteryInfo

    private var batteryColor: Color {
        if batteryInfo.isCharging {
            return .green
        }
        if batteryInfo.level > 50 {
            return .batteryGradientStart
        } else if batteryInfo.level > 20 {
            return .orange
        }
        return .red
    }

    var body: some View {
        CardContainerView(
            title: "电池",
            iconName: batteryInfo.isCharging ? "battery.100.bolt" : "battery.100",
            iconColor: batteryColor
        ) {
            if batteryInfo.hasBattery {
                VStack(spacing: 16) {
                    // 电池图形
                    BatteryIndicatorView(
                        level: batteryInfo.level,
                        isCharging: batteryInfo.isCharging,
                        color: batteryColor
                    )
                    .frame(height: 60)

                    // 状态文字
                    Text(batteryInfo.statusText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    // 详细信息
                    VStack(spacing: 8) {
                        InfoRowView(
                            label: "电量",
                            value: ByteFormatter.formatPercentage(batteryInfo.level),
                            valueColor: batteryColor
                        )

                        if let health = batteryInfo.health {
                            InfoRowView(
                                label: "电池健康",
                                value: ByteFormatter.formatPercentage(health),
                                valueColor: health > 80 ? .green : .orange
                            )
                        }

                        if let cycleCount = batteryInfo.cycleCount {
                            InfoRowView(
                                label: "循环次数",
                                value: "\(cycleCount)"
                            )
                        }

                        InfoRowView(
                            label: "电源",
                            value: batteryInfo.isPluggedIn ? "已连接" : "使用电池"
                        )
                    }
                }
            } else {
                // 无电池设备
                VStack(spacing: 16) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)

                    Text("已连接电源")
                        .font(.headline)

                    Text("此设备没有内置电池")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
    }
}

struct BatteryIndicatorView: View {
    let level: Double
    let isCharging: Bool
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let batteryWidth = min(geometry.size.width * 0.7, 120)
            let batteryHeight: CGFloat = 50
            let capWidth: CGFloat = 6
            let cornerRadius: CGFloat = 8
            let padding: CGFloat = 4

            HStack(spacing: 0) {
                Spacer()

                ZStack(alignment: .leading) {
                    // 电池外壳
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                        .frame(width: batteryWidth, height: batteryHeight)

                    // 电量填充
                    RoundedRectangle(cornerRadius: cornerRadius - padding)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max((batteryWidth - padding * 2) * (level / 100), 0),
                            height: batteryHeight - padding * 2
                        )
                        .padding(.leading, padding)

                    // 充电指示
                    if isCharging {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: batteryWidth, height: batteryHeight)
                    }

                    // 电量百分比
                    Text(String(format: "%.0f%%", level))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(level > 50 ? .white : .primary)
                        .frame(width: batteryWidth, height: batteryHeight)
                }

                // 电池正极
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: capWidth, height: batteryHeight * 0.4)

                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BatteryCardView(batteryInfo: BatteryInfo.placeholder)
        BatteryCardView(batteryInfo: BatteryInfo.noBattery)
    }
    .frame(width: 220)
    .padding()
}
