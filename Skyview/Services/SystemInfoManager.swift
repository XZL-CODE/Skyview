//
//  SystemInfoManager.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import Combine
import AppKit

/// 持有所有面向 UI 的系统状态。
/// 实际采集由 MetricsCollector 在后台串行队列执行, 结果回主线程发布。
class SystemInfoManager: ObservableObject {
    @Published var systemInfo: SystemInfo
    @Published var cpuInfo: CPUInfo
    @Published var memoryInfo: MemoryInfo
    @Published var storageInfo: StorageInfo
    @Published var networkInfo: NetworkInfo
    @Published var batteryInfo: BatteryInfo

    @Published var gpuInfo: [GPUInfo] = []
    @Published var displayInfo: [DisplayInfo] = []
    @Published var audioDevices: [AudioDeviceInfo] = []
    @Published var usbDevices: [USBDeviceInfo] = []
    @Published var diskIOInfo: DiskIOInfo = .placeholder
    @Published var topProcesses: [ProcessInfoItem] = []
    @Published var bluetoothDevices: [BluetoothDeviceInfo] = []
    @Published var topApps: [AppInfo] = []

    @Published var cpuHistory: [Double] = []
    @Published var memoryHistory: [Double] = []
    @Published var downloadHistory: [Double] = []
    @Published var uploadHistory: [Double] = []
    @Published var diskReadHistory: [Double] = []
    @Published var diskWriteHistory: [Double] = []

    private let collector = MetricsCollector()
    private let alertService = AlertService()

    private var cpuHistoryBuffer: RingBuffer<Double>
    private var memoryHistoryBuffer: RingBuffer<Double>
    private var downloadHistoryBuffer: RingBuffer<Double>
    private var uploadHistoryBuffer: RingBuffer<Double>
    private var diskReadHistoryBuffer: RingBuffer<Double>
    private var diskWriteHistoryBuffer: RingBuffer<Double>

    private var activityObservers: [NSObjectProtocol] = []
    private let historySize = 60

    init() {
        self.systemInfo = SystemInfo.placeholder
        self.cpuInfo = CPUInfo.placeholder
        self.memoryInfo = MemoryInfo.placeholder
        self.storageInfo = StorageInfo.placeholder
        self.networkInfo = NetworkInfo.placeholder
        self.batteryInfo = BatteryInfo.placeholder

        self.cpuHistoryBuffer = RingBuffer(capacity: historySize, defaultValue: 0.0)
        self.memoryHistoryBuffer = RingBuffer(capacity: historySize, defaultValue: 0.0)
        self.downloadHistoryBuffer = RingBuffer(capacity: historySize, defaultValue: 0.0)
        self.uploadHistoryBuffer = RingBuffer(capacity: historySize, defaultValue: 0.0)
        self.diskReadHistoryBuffer = RingBuffer(capacity: historySize, defaultValue: 0.0)
        self.diskWriteHistoryBuffer = RingBuffer(capacity: historySize, defaultValue: 0.0)

        collector.onUpdate = { [weak self] update in
            DispatchQueue.main.async {
                self?.apply(update)
            }
        }
        collector.start()
        observeAppActivity()
    }

    deinit {
        activityObservers.forEach { NotificationCenter.default.removeObserver($0) }
        collector.stop()
    }

    // MARK: - 发布采集结果

    private func apply(_ update: MetricsUpdate) {
        if let value = update.system { systemInfo = value }

        if let value = update.cpu {
            cpuInfo = value
            cpuHistoryBuffer.append(value.usage)
            cpuHistory = cpuHistoryBuffer.toArray()
        }

        if let value = update.memory {
            memoryInfo = value
            memoryHistoryBuffer.append(value.usagePercentage)
            memoryHistory = memoryHistoryBuffer.toArray()
        }

        if let value = update.network {
            networkInfo = value
            downloadHistoryBuffer.append(value.downloadSpeed)
            uploadHistoryBuffer.append(value.uploadSpeed)
            downloadHistory = downloadHistoryBuffer.toArray()
            uploadHistory = uploadHistoryBuffer.toArray()
        }

        if let value = update.diskIO {
            diskIOInfo = value
            diskReadHistoryBuffer.append(value.readSpeed)
            diskWriteHistoryBuffer.append(value.writeSpeed)
            diskReadHistory = diskReadHistoryBuffer.toArray()
            diskWriteHistory = diskWriteHistoryBuffer.toArray()
        }

        if let value = update.storage { storageInfo = value }
        if let value = update.battery { batteryInfo = value }
        if let value = update.gpu { gpuInfo = value }
        if let value = update.display { displayInfo = value }
        if let value = update.audio { audioDevices = value }
        if let value = update.usb { usbDevices = value }
        if let value = update.processes { topProcesses = value }
        if let value = update.bluetooth { bluetoothDevices = value }
        if let value = update.apps { topApps = value }

        alertService.evaluate(cpu: update.cpu, memory: update.memory, storage: update.storage)
    }

    // MARK: - 前后台降频

    /// 菜单栏面板显隐: 打开时临时恢复全速刷新, 关闭后按当前活跃状态恢复
    func menuBarPanelChanged(visible: Bool) {
        collector.setThrottled(visible ? false : shouldThrottleNow())
    }

    private func shouldThrottleNow() -> Bool {
        UserDefaults.standard.bool(forKey: SettingsKeys.throttleWhenInactive)
            && !NSApplication.shared.isActive
    }

    private func observeAppActivity() {
        let center = NotificationCenter.default
        activityObservers.append(center.addObserver(
            forName: NSApplication.didResignActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.collector.setThrottled(self.shouldThrottleNow())
        })
        activityObservers.append(center.addObserver(
            forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.collector.setThrottled(false)
        })
    }
}
