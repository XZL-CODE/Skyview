//
//  SettingsView.swift
//  Skyview
//
//  Created by xzl on 2026/6/10.
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("通用", systemImage: "gear") }

            MenuBarSettingsView()
                .tabItem { Label("菜单栏", systemImage: "menubar.rectangle") }

            AlertSettingsView()
                .tabItem { Label("通知", systemImage: "bell") }
        }
        .frame(width: 440)
    }
}

// MARK: - 通用

struct GeneralSettingsView: View {
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var loginItemError: String?
    @AppStorage(SettingsKeys.throttleWhenInactive) private var throttleWhenInactive = true

    var body: some View {
        Form {
            Toggle("登录时启动", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { newValue in
                    updateLoginItem(enabled: newValue)
                }
            if let loginItemError {
                Text(loginItemError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Toggle("窗口非活跃时降低刷新频率", isOn: $throttleWhenInactive)
            Text("降低 Skyview 自身能耗，回到前台时自动恢复全速刷新。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
    }

    private func updateLoginItem(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            loginItemError = nil
        } catch {
            loginItemError = error.localizedDescription
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}

// MARK: - 菜单栏

struct MenuBarSettingsView: View {
    @AppStorage(SettingsKeys.showMenuBarExtra) private var showMenuBarExtra = true
    @AppStorage(SettingsKeys.menuBarStyle) private var styleRaw = MenuBarStyle.cpu.rawValue

    var body: some View {
        Form {
            Toggle("在菜单栏显示", isOn: $showMenuBarExtra)

            Picker("显示内容", selection: $styleRaw) {
                ForEach(MenuBarStyle.allCases) { style in
                    Text(style.displayName).tag(style.rawValue)
                }
            }
            .pickerStyle(.radioGroup)
            .disabled(!showMenuBarExtra)
        }
        .padding(20)
    }
}

// MARK: - 通知

struct AlertSettingsView: View {
    @AppStorage(SettingsKeys.alertsEnabled) private var alertsEnabled = false
    @AppStorage(SettingsKeys.alertCPUThreshold) private var cpuThreshold = 90.0
    @AppStorage(SettingsKeys.alertMemoryThreshold) private var memoryThreshold = 90.0
    @AppStorage(SettingsKeys.alertDiskFreeThreshold) private var diskFreeThreshold = 10.0

    var body: some View {
        Form {
            Toggle("启用阈值告警", isOn: $alertsEnabled)
                .onChange(of: alertsEnabled) { enabled in
                    if enabled {
                        AlertService.requestAuthorization()
                    }
                }
            Text("指标越界时发送系统通知，同类告警 5 分钟内只提醒一次。")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()
                .padding(.vertical, 4)

            thresholdRow(title: "CPU 使用率超过", value: $cpuThreshold, range: 50...100, step: 5)
            thresholdRow(title: "内存使用率超过", value: $memoryThreshold, range: 50...100, step: 5)
            thresholdRow(title: "磁盘剩余空间低于", value: $diskFreeThreshold, range: 1...30, step: 1)
        }
        .padding(20)
    }

    private func thresholdRow(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        HStack {
            Text(title)
                .frame(width: 140, alignment: .leading)
            Slider(value: value, in: range, step: step)
            Text("\(Int(value.wrappedValue))%")
                .monospacedDigit()
                .frame(width: 44, alignment: .trailing)
        }
        .disabled(!alertsEnabled)
    }
}

#Preview {
    SettingsView()
}
