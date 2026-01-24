//
//  ProcessDetailView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct ProcessDetailView: View {
    @ObservedObject var manager: SystemInfoManager
    @State private var sortOrder: ProcessSortOrder = .cpu

    var sortedProcesses: [ProcessInfoItem] {
        switch sortOrder {
        case .cpu:
            return manager.topProcesses.sorted { $0.cpuUsage > $1.cpuUsage }
        case .memory:
            return manager.topProcesses.sorted { $0.memoryUsage > $1.memoryUsage }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "进程监控",
                    subtitle: "Top 10 进程",
                    icon: "list.bullet.rectangle",
                    gradient: [.processGradientStart, .processGradientEnd]
                )

                // 排序选择器
                HStack {
                    Text("排序方式")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Picker("排序", selection: $sortOrder) {
                        Text("CPU 使用率").tag(ProcessSortOrder.cpu)
                        Text("内存占用").tag(ProcessSortOrder.memory)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.cardBackground)
                .cornerRadius(12)

                // 进程列表
                VStack(spacing: 0) {
                    // 表头
                    ProcessHeaderRow()

                    Divider()

                    // 进程行
                    ForEach(Array(sortedProcesses.enumerated()), id: \.element.id) { index, process in
                        ProcessRowView(process: process, rank: index + 1, sortOrder: sortOrder)

                        if index < sortedProcesses.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
                .background(Color.cardBackground)
                .cornerRadius(20)

                // 系统资源概览
                ProcessResourceSummary(processes: manager.topProcesses)
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct ProcessHeaderRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("#")
                .frame(width: 24, alignment: .center)

            Text("进程名称")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("PID")
                .frame(width: 60, alignment: .trailing)

            Text("用户")
                .frame(width: 80, alignment: .trailing)

            Text("线程")
                .frame(width: 50, alignment: .trailing)

            Text("CPU")
                .frame(width: 70, alignment: .trailing)

            Text("内存")
                .frame(width: 80, alignment: .trailing)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct ProcessRowView: View {
    let process: ProcessInfoItem
    let rank: Int
    let sortOrder: ProcessSortOrder

    var rankColor: Color {
        switch rank {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // 排名
            ZStack {
                Circle()
                    .fill(rankColor.opacity(rank <= 3 ? 0.15 : 0.05))
                    .frame(width: 24, height: 24)

                Text("\(rank)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(rank <= 3 ? rankColor : .secondary)
            }

            // 进程名称
            VStack(alignment: .leading, spacing: 2) {
                Text(process.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // PID
            Text("\(process.pid)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)

            // 用户
            Text(process.user)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .trailing)
                .lineLimit(1)

            // 线程数
            Text("\(process.threads)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)

            // CPU
            HStack(spacing: 4) {
                if sortOrder == .cpu {
                    CPUBar(usage: process.cpuUsage)
                }
                Text(process.cpuFormatted)
                    .font(.system(size: 12, weight: sortOrder == .cpu ? .semibold : .regular, design: .rounded))
                    .foregroundColor(sortOrder == .cpu ? .processGradientStart : .secondary)
            }
            .frame(width: 70, alignment: .trailing)

            // 内存
            Text(process.memoryFormatted)
                .font(.system(size: 12, weight: sortOrder == .memory ? .semibold : .regular, design: .rounded))
                .foregroundColor(sortOrder == .memory ? .processGradientStart : .secondary)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(rank <= 3 ? rankColor.opacity(0.03) : Color.clear)
    }
}

struct CPUBar: View {
    let usage: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.2))

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.processGradientStart)
                    .frame(width: geometry.size.width * min(usage / 100, 1.0))
            }
        }
        .frame(width: 30, height: 6)
    }
}

struct ProcessResourceSummary: View {
    let processes: [ProcessInfoItem]

    var totalCPU: Double {
        processes.reduce(0) { $0 + $1.cpuUsage }
    }

    var totalMemory: UInt64 {
        processes.reduce(0) { $0 + $1.memoryUsage }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top 10 资源占用统计")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(String(format: "%.1f%%", totalCPU))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.processGradientStart)

                    Text("CPU 总占用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)

                VStack(spacing: 8) {
                    Text(ByteFormatter.format(totalMemory))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.memoryGradientStart)

                    Text("内存总占用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

#Preview {
    ProcessDetailView(manager: SystemInfoManager())
        .frame(width: 700, height: 700)
}
