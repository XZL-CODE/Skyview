//
//  OverviewView.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI
import Combine

struct OverviewView: View {
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 顶部欢迎栏
                WelcomeHeaderView(systemInfo: manager.systemInfo)

                // 主要指标 - 大卡片
                HStack(spacing: 16) {
                    OverviewGaugeCard(
                        title: "CPU",
                        value: manager.cpuInfo.usage,
                        icon: "cpu",
                        gradient: [.cpuGradientStart, .cpuGradientEnd],
                        subtitle: "\(manager.cpuInfo.coreCount) 核心"
                    )

                    OverviewGaugeCard(
                        title: "内存",
                        value: manager.memoryInfo.usagePercentage,
                        icon: "memorychip",
                        gradient: [.memoryGradientStart, .memoryGradientEnd],
                        subtitle: ByteFormatter.format(manager.memoryInfo.used) + " / " + ByteFormatter.format(manager.memoryInfo.total)
                    )
                }

                // GPU 和 磁盘 I/O
                HStack(spacing: 16) {
                    OverviewGPUCard(gpuInfo: manager.gpuInfo)
                    OverviewDiskIOCard(diskIO: manager.diskIOInfo)
                }

                // 存储和网络
                HStack(spacing: 16) {
                    OverviewStorageCard(storageInfo: manager.storageInfo)
                    OverviewNetworkCard(networkInfo: manager.networkInfo)
                }

                // 进程 Top 3
                OverviewProcessCard(processes: manager.topProcesses)

                // 底部 - 电池和系统
                HStack(spacing: 16) {
                    OverviewBatteryCard(batteryInfo: manager.batteryInfo)
                    OverviewSystemCard(systemInfo: manager.systemInfo)
                }

                // 实时趋势图
                OverviewTrendsCard(
                    cpuHistory: manager.cpuHistory,
                    memoryHistory: manager.memoryHistory
                )
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct WelcomeHeaderView: View {
    let systemInfo: SystemInfo

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(getGreeting())
                    .font(.title2)
                    .fontWeight(.bold)

                Text("\(systemInfo.hostname) · 运行 \(systemInfo.uptime.formatUptime())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 实时时间
            TimeDisplayView()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 6 { return String(localized: "夜深了") }
        if hour < 12 { return String(localized: "早上好") }
        if hour < 18 { return String(localized: "下午好") }
        return String(localized: "晚上好")
    }
}

struct TimeDisplayView: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(currentTime, style: .time)
                .font(.system(size: 28, weight: .light, design: .rounded))

            Text(currentTime, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }
}

struct OverviewGaugeCard: View {
    let title: LocalizedStringKey
    let value: Double
    let icon: String
    let gradient: [Color]
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))

                Text(title)
                    .font(.headline)

                Spacer()
            }

            ZStack {
                // 背景圆环
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 14)

                // 进度圆环
                Circle()
                    .trim(from: 0, to: min(value / 100, 1.0))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: gradient + [gradient[0]]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: value)

                // 中心数值
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", value))
                        .font(.system(size: 36, weight: .bold, design: .rounded))

                    Text("%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120, height: 120)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct OverviewStorageCard: View {
    let storageInfo: StorageInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "internaldrive")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [.storageGradientStart, .storageGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))

                Text("存储")
                    .font(.headline)

                Spacer()

                Text(String(format: "%.1f%%", storageInfo.usagePercentage))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }

            // 存储条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.15))

                    RoundedRectangle(cornerRadius: 8)
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
            .frame(height: 16)

            HStack {
                Label(ByteFormatter.format(storageInfo.used), systemImage: "square.fill")
                    .font(.caption)
                    .foregroundColor(.storageGradientStart)

                Spacer()

                Label(ByteFormatter.format(storageInfo.free) + " 可用", systemImage: "square")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct OverviewNetworkCard: View {
    let networkInfo: NetworkInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "network")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [.networkGradientStart, .networkGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))

                Text("网络")
                    .font(.headline)

                Spacer()

                if let ip = networkInfo.ipAddress {
                    Text(ip)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
            }

            HStack(spacing: 20) {
                // 下载
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.green)

                    Text(ByteFormatter.formatSpeed(networkInfo.downloadSpeed))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))

                    Text("下载")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 60)

                // 上传
                VStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)

                    Text(ByteFormatter.formatSpeed(networkInfo.uploadSpeed))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))

                    Text("上传")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct OverviewBatteryCard: View {
    let batteryInfo: BatteryInfo

    var batteryColor: Color {
        if batteryInfo.isCharging { return .green }
        if batteryInfo.level > 50 { return .batteryGradientStart }
        if batteryInfo.level > 20 { return .orange }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: batteryInfo.isCharging ? "battery.100.bolt" : "battery.100")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(batteryColor)

                Text("电池")
                    .font(.headline)

                Spacer()

                if batteryInfo.hasBattery {
                    Text(batteryInfo.statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if batteryInfo.hasBattery {
                HStack(spacing: 16) {
                    // 电池图形
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 60, height: 30)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(batteryColor)
                            .frame(width: 54 * (batteryInfo.level / 100), height: 24)
                            .frame(width: 54, alignment: .leading)

                        if batteryInfo.isCharging {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "%.0f%%", batteryInfo.level))
                            .font(.system(size: 24, weight: .bold, design: .rounded))

                        if let health = batteryInfo.health {
                            Text("健康度 \(String(format: "%.0f%%", health))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                }
            } else {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)

                    Text("已连接电源")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct OverviewSystemCard: View {
    let systemInfo: SystemInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [.systemGradientStart, .systemGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))

                Text("系统")
                    .font(.headline)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("型号")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(systemInfo.modelName)
                        .font(.caption)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("处理器")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(truncateProcessor(systemInfo.processorName))
                        .font(.caption)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("内存")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(ByteFormatter.format(systemInfo.physicalMemory, decimals: 0))
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private func truncateProcessor(_ name: String) -> String {
        var result = name
            .replacingOccurrences(of: "(R)", with: "")
            .replacingOccurrences(of: "(TM)", with: "")
            .trimmingCharacters(in: .whitespaces)
        if result.count > 18 {
            if let range = result.range(of: "@") {
                result = String(result[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
        }
        return result
    }
}

struct OverviewTrendsCard: View {
    let cpuHistory: [Double]
    let memoryHistory: [Double]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))

                Text("实时趋势")
                    .font(.headline)

                Spacer()

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.cpuGradientStart).frame(width: 8, height: 8)
                        Text("CPU").font(.caption).foregroundColor(.secondary)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.memoryGradientStart).frame(width: 8, height: 8)
                        Text("内存").font(.caption).foregroundColor(.secondary)
                    }
                }
            }

            ZStack {
                SparklineChartView(
                    data: cpuHistory,
                    lineColor: .cpuGradientStart,
                    height: 80
                )

                SparklineChartView(
                    data: memoryHistory,
                    lineColor: .memoryGradientStart,
                    fillGradient: [Color.memoryGradientStart.opacity(0.2), Color.memoryGradientStart.opacity(0)],
                    height: 80
                )
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - GPU Card
struct OverviewGPUCard: View {
    let gpuInfo: [GPUInfo]

    var primaryGPU: GPUInfo? {
        gpuInfo.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "rectangle.3.group")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [.gpuGradientStart, .gpuGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))

                Text("GPU")
                    .font(.headline)

                Spacer()

                if let gpu = primaryGPU {
                    if gpu.supportsRaytracing {
                        Text("光追")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.15))
                            .foregroundColor(.purple)
                            .cornerRadius(4)
                    }
                }
            }

            if let gpu = primaryGPU {
                VStack(alignment: .leading, spacing: 8) {
                    Text(gpu.name)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("推荐显存")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(gpu.recommendedMemoryFormatted)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                        }

                        Divider()
                            .frame(height: 30)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("GPU 数量")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(gpuInfo.count)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                        }
                    }
                }
            } else {
                Text("未检测到 GPU")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Disk I/O Card
struct OverviewDiskIOCard: View {
    let diskIO: DiskIOInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.up.arrow.down.circle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [.diskIOGradientStart, .diskIOGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))

                Text("磁盘 I/O")
                    .font(.headline)

                Spacer()
            }

            HStack(spacing: 20) {
                // 读取
                VStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)

                    Text(diskIO.readSpeedFormatted)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))

                    Text("读取")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 50)

                // 写入
                VStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)

                    Text(diskIO.writeSpeedFormatted)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))

                    Text("写入")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Process Card
struct OverviewProcessCard: View {
    let processes: [ProcessInfoItem]

    var top3: [ProcessInfoItem] {
        Array(processes.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [.processGradientStart, .processGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))

                Text("Top 进程")
                    .font(.headline)

                Spacer()

                Text("\(processes.count) 进程")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }

            if !top3.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(top3.enumerated()), id: \.element.id) { index, process in
                        HStack(spacing: 12) {
                            // 排名
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .frame(width: 20, height: 20)
                                .background(rankColor(index).opacity(0.15))
                                .foregroundColor(rankColor(index))
                                .cornerRadius(6)

                            // 名称
                            Text(process.name)
                                .font(.subheadline)
                                .lineLimit(1)

                            Spacer()

                            // CPU
                            HStack(spacing: 4) {
                                Image(systemName: "cpu")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(process.cpuFormatted)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                            }

                            // 内存
                            HStack(spacing: 4) {
                                Image(systemName: "memorychip")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(process.memoryFormatted)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
            } else {
                Text("暂无进程数据")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return .red
        case 1: return .orange
        case 2: return .yellow
        default: return .gray
        }
    }
}

#Preview {
    OverviewView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
