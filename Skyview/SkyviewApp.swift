//
//  SkyviewApp.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

@main
struct SkyviewApp: App {
    @StateObject private var manager: SystemInfoManager
    @AppStorage(SettingsKeys.showMenuBarExtra) private var showMenuBarExtra = true

    init() {
        SettingsKeys.registerDefaults()
        _manager = StateObject(wrappedValue: SystemInfoManager())
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(manager)
        }
        .defaultSize(width: 900, height: 700)
        .windowResizability(.contentMinSize)

        Settings {
            SettingsView()
        }

        MenuBarExtra(isInserted: $showMenuBarExtra) {
            MenuBarPanelView()
                .environmentObject(manager)
        } label: {
            MenuBarLabel(manager: manager)
        }
        .menuBarExtraStyle(.window)
    }
}
