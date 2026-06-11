//
//  MenuBarViews.swift
//  Skyview
//
//  Created by xzl on 2026/6/10.
//

import SwiftUI

// MARK: - 菜单栏标签

struct MenuBarLabel: View {
    @ObservedObject var manager: SystemInfoManager
    @AppStorage(SettingsKeys.menuBarStyle) private var styleRaw = MenuBarStyle.cpu.rawValue

    var body: some View {
        let cpu = Int(manager.cpuInfo.usage.rounded())
        let memory = Int(manager.memoryInfo.usagePercentage.rounded())

        switch MenuBarStyle(rawValue: styleRaw) ?? .cpu {
        case .cpu:
            Label("\(cpu)%", systemImage: "cpu")
        case .memory:
            Label("\(memory)%", systemImage: "memorychip")
        case .both:
            Text("\(cpu)% · \(memory)%")
        }
    }
}

// MARK: - 菜单栏速览面板

struct MenuBarPanelView: View {
    @EnvironmentObject var manager: SystemInfoManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            metricRow(
                icon: "cpu",
                title: "CPU",
                value: String(format: "%.0f%%", manager.cpuInfo.usage),
                progress: manager.cpuInfo.usage / 100
            )

            metricRow(
                icon: "memorychip",
                title: "内存",
                value: String(format: "%.0f%%", manager.memoryInfo.usagePercentage),
                progress: manager.memoryInfo.usagePercentage / 100
            )

            Divider()

            HStack(spacing: 14) {
                Label(ByteFormatter.formatSpeed(manager.networkInfo.downloadSpeed), systemImage: "arrow.down")
                Label(ByteFormatter.formatSpeed(manager.networkInfo.uploadSpeed), systemImage: "arrow.up")
                Spacer()
            }
            .font(.callout)
            .foregroundStyle(.secondary)

            if !manager.topProcesses.isEmpty {
                Divider()

                Text("CPU 占用 Top 3")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(manager.topProcesses.prefix(3), id: \.pid) { process in
                    HStack {
                        Text(process.name)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Text(String(format: "%.1f%%", process.cpuUsage))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .font(.callout)
                }
            }

            Divider()

            HStack {
                Button("打开 Skyview") {
                    openMainWindow()
                }

                Spacer()

                settingsButton

                Button("退出") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .controlSize(.small)
        }
        .padding(14)
        .frame(width: 280)
        .onAppear { manager.menuBarPanelChanged(visible: true) }
        .onDisappear { manager.menuBarPanelChanged(visible: false) }
    }

    @ViewBuilder
    private var settingsButton: some View {
        if #available(macOS 14.0, *) {
            SettingsLink {
                Text("设置…")
            }
        } else {
            Button("设置…") {
                // macOS 13 没有 SettingsLink, 走 AppKit 私有 selector
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    private func openMainWindow() {
        openWindow(id: "main")
        NSApp.activate(ignoringOtherApps: true)
    }

    private func metricRow(icon: String, title: LocalizedStringKey, value: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.callout)
                Spacer()
                Text(value)
                    .font(.callout)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: min(max(progress, 0), 1))
                .progressViewStyle(.linear)
                .controlSize(.small)
        }
    }
}
