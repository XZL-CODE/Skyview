//
//  MainView.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var manager: SystemInfoManager
    @State private var selectedItem: NavigationItem = .overview

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selectedItem, manager: manager)
        } detail: {
            DetailView(selectedItem: selectedItem, manager: manager)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct DetailView: View {
    let selectedItem: NavigationItem
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        Group {
            switch selectedItem {
            case .overview:
                OverviewView(manager: manager)
            case .cpu:
                CPUDetailView(manager: manager)
            case .memory:
                MemoryDetailView(manager: manager)
            case .gpu:
                GPUDetailView(manager: manager)
            case .storage:
                StorageDetailView(manager: manager)
            case .diskIO:
                DiskIODetailView(manager: manager)
            case .network:
                NetworkDetailView(manager: manager)
            case .application:
                ApplicationDetailView(manager: manager)
            case .process:
                ProcessDetailView(manager: manager)
            case .display:
                DisplayDetailView(manager: manager)
            case .audio:
                AudioDetailView(manager: manager)
            case .usb:
                USBDetailView(manager: manager)
            case .bluetooth:
                BluetoothDetailView(manager: manager)
            case .battery:
                BatteryDetailView(manager: manager)
            case .system:
                SystemDetailView(manager: manager)
            }
        }
        .frame(minWidth: 500)
    }
}

#Preview {
    MainView()
        .environmentObject(SystemInfoManager())
        .frame(width: 900, height: 700)
}
