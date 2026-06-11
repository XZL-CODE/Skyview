//
//  MetricsCollector.swift
//  Skyview
//
//  Created by xzl on 2026/6/10.
//

import Foundation
import Darwin

/// 一次采集产出的增量数据包。
/// 字段为 nil 表示该域本轮未刷新 (各域刷新频率不同)。
nonisolated struct MetricsUpdate {
    var system: SystemInfo?
    var cpu: CPUInfo?
    var memory: MemoryInfo?
    var storage: StorageInfo?
    var network: NetworkInfo?
    var battery: BatteryInfo?
    var gpu: [GPUInfo]?
    var display: [DisplayInfo]?
    var audio: [AudioDeviceInfo]?
    var usb: [USBDeviceInfo]?
    var diskIO: DiskIOInfo?
    var processes: [ProcessInfoItem]?
    var bluetooth: [BluetoothDeviceInfo]?
    var apps: [AppInfo]?
}

/// 后台采集器: 单一心跳定时器跑在专用串行队列上, 按各域周期分频采集。
/// 所有 monitor 的可变状态都只在这条队列上访问, 结果通过 onUpdate 回调交出。
/// @unchecked Sendable 的依据正是上述串行队列约束。
nonisolated final class MetricsCollector: @unchecked Sendable {
    /// 采集结果回调, 在内部队列上调用, 由持有方负责切回主线程
    var onUpdate: ((MetricsUpdate) -> Void)?

    private let queue = DispatchQueue(label: "com.xzl.skyview.metrics", qos: .utility)
    private var timer: DispatchSourceTimer?
    private var tick: UInt64 = 0
    /// 非活跃降频倍率 (1 = 全速, 5 = 降频)。仅在 queue 上访问
    private var throttleMultiplier: UInt64 = 1

    private let cpuMonitor = CPUMonitor()
    private let memoryMonitor = MemoryMonitor()
    private let storageMonitor = StorageMonitor()
    private let networkMonitor = NetworkMonitor()
    private let batteryMonitor = BatteryMonitor()
    private let gpuMonitor = GPUMonitor()
    private let displayMonitor = DisplayMonitor()
    private let audioMonitor = AudioMonitor()
    private let usbMonitor = USBMonitor()
    private let diskIOMonitor = DiskIOMonitor()
    private let processMonitor = ProcessMonitor()
    private let bluetoothMonitor = BluetoothMonitor()
    private let applicationMonitor = ApplicationMonitor()

    /// GPU 的 Metal 能力信息是静态的, 启动时采集一次后缓存
    private var cachedGPUInfo: [GPUInfo]?

    deinit {
        timer?.cancel()
    }

    func start() {
        queue.async { [weak self] in
            guard let self else { return }
            self.onUpdate?(self.collectAll())
        }

        let source = DispatchSource.makeTimerSource(queue: queue)
        source.schedule(deadline: .now() + 1.0, repeating: 1.0, leeway: .milliseconds(100))
        source.setEventHandler { [weak self] in
            self?.handleTick()
        }
        source.resume()
        timer = source
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    /// 应用非活跃时降低采集频率, 减少自身能耗
    func setThrottled(_ throttled: Bool) {
        queue.async { [weak self] in
            guard let self else { return }
            let multiplier: UInt64 = throttled ? 5 : 1
            guard multiplier != self.throttleMultiplier else { return }
            self.throttleMultiplier = multiplier

            if !throttled {
                // 回到前台立即刷一轮高频指标, 避免界面显示陈旧数据
                var update = MetricsUpdate()
                update.cpu = self.cpuMonitor.getCPUInfo()
                update.network = self.networkMonitor.getNetworkInfo()
                update.memory = self.memoryMonitor.getMemoryInfo()
                update.diskIO = self.diskIOMonitor.getDiskIOInfo()
                self.onUpdate?(update)
            }
        }
    }

    // MARK: - 心跳分频

    private func handleTick() {
        tick &+= 1
        let m = throttleMultiplier

        var update = MetricsUpdate()
        var hasChanges = false

        // CPU / 网络: 1s (速率类高频指标)
        if tick % (1 * m) == 0 {
            update.cpu = cpuMonitor.getCPUInfo()
            update.network = networkMonitor.getNetworkInfo()
            hasChanges = true
        }

        // 内存 / 磁盘 I/O: 2s
        if tick % (2 * m) == 0 {
            update.memory = memoryMonitor.getMemoryInfo()
            update.diskIO = diskIOMonitor.getDiskIOInfo()
            hasChanges = true
        }

        // 进程 / 应用: 3s
        if tick % (3 * m) == 0 {
            update.processes = processMonitor.getTopProcesses(limit: 10, sortBy: .cpu)
            update.apps = applicationMonitor.getTopMemoryApps(limit: 10)
            hasChanges = true
        }

        // 存储 / 电池 / 音频 / USB / 蓝牙: 30s
        if tick % (30 * m) == 0 {
            update.storage = storageMonitor.getStorageInfo()
            update.battery = batteryMonitor.getBatteryInfo()
            update.audio = audioMonitor.getAudioDevices()
            update.usb = usbMonitor.getUSBDevices()
            update.bluetooth = bluetoothMonitor.getBluetoothDevices()
            hasChanges = true
        }

        // 系统信息 (uptime 等) / 显示器: 60s
        if tick % (60 * m) == 0 {
            update.system = collectSystemInfo()
            update.display = displayMonitor.getDisplayInfo()
            hasChanges = true
        }

        if hasChanges {
            onUpdate?(update)
        }
    }

    private func collectAll() -> MetricsUpdate {
        var update = MetricsUpdate()
        update.system = collectSystemInfo()
        update.cpu = cpuMonitor.getCPUInfo()
        update.memory = memoryMonitor.getMemoryInfo()
        update.storage = storageMonitor.getStorageInfo()
        update.network = networkMonitor.getNetworkInfo()
        update.battery = batteryMonitor.getBatteryInfo()
        update.gpu = cachedGPU()
        update.display = displayMonitor.getDisplayInfo()
        update.audio = audioMonitor.getAudioDevices()
        update.usb = usbMonitor.getUSBDevices()
        update.diskIO = diskIOMonitor.getDiskIOInfo()
        update.processes = processMonitor.getTopProcesses(limit: 10, sortBy: .cpu)
        update.bluetooth = bluetoothMonitor.getBluetoothDevices()
        update.apps = applicationMonitor.getTopMemoryApps(limit: 10)
        return update
    }

    private func cachedGPU() -> [GPUInfo] {
        if let cached = cachedGPUInfo {
            return cached
        }
        let info = gpuMonitor.getGPUInfo()
        cachedGPUInfo = info
        return info
    }

    // MARK: - 系统静态信息

    private func collectSystemInfo() -> SystemInfo {
        let processInfo = ProcessInfo.processInfo

        let hostname = Host.current().localizedName ?? processInfo.hostName
        let osVersion = processInfo.operatingSystemVersionString

        var kernelVersion = "Darwin"
        var size: Int = 0
        sysctlbyname("kern.osrelease", nil, &size, nil, 0)
        if size > 0 {
            var release = [CChar](repeating: 0, count: size)
            sysctlbyname("kern.osrelease", &release, &size, nil, 0)
            kernelVersion = "Darwin \(String(cString: release))"
        }

        var boottime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        size = MemoryLayout<timeval>.stride
        sysctl(&mib, 2, &boottime, &size, nil, 0)
        let uptime = Date().timeIntervalSince1970 - Double(boottime.tv_sec)

        return SystemInfo(
            hostname: hostname,
            osVersion: osVersion,
            kernelVersion: kernelVersion,
            uptime: uptime,
            modelName: getModelName(),
            processorName: getProcessorBrandString(),
            processorCount: processInfo.processorCount,
            physicalMemory: processInfo.physicalMemory
        )
    }

    private func getModelName() -> String {
        var size: Int = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        guard size > 0 else { return "Mac" }

        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        let modelIdentifier = String(cString: model)

        if modelIdentifier.contains("MacBookPro") {
            return "MacBook Pro"
        } else if modelIdentifier.contains("MacBookAir") {
            return "MacBook Air"
        } else if modelIdentifier.contains("MacBook") {
            return "MacBook"
        } else if modelIdentifier.contains("iMac") {
            return "iMac"
        } else if modelIdentifier.contains("Macmini") {
            return "Mac mini"
        } else if modelIdentifier.contains("MacPro") {
            return "Mac Pro"
        }
        // M2 之后的机型标识符是 "Mac14,x" 这类格式, 无法从前缀判断形态, 直接显示标识符
        return modelIdentifier
    }

    private func getProcessorBrandString() -> String {
        var size: Int = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)

        if size > 0 {
            var brand = [CChar](repeating: 0, count: size)
            sysctlbyname("machdep.cpu.brand_string", &brand, &size, nil, 0)
            return String(cString: brand)
        }

        return "Apple Silicon"
    }
}
