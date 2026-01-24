//
//  SystemInfoManager.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import Combine
import Darwin

class SystemInfoManager: ObservableObject {
    @Published var systemInfo: SystemInfo
    @Published var cpuInfo: CPUInfo
    @Published var memoryInfo: MemoryInfo
    @Published var storageInfo: StorageInfo
    @Published var networkInfo: NetworkInfo
    @Published var batteryInfo: BatteryInfo

    // 新增模块
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

    private let cpuMonitor = CPUMonitor()
    private let memoryMonitor = MemoryMonitor()
    private let storageMonitor = StorageMonitor()
    private let networkMonitor = NetworkMonitor()
    private let batteryMonitor = BatteryMonitor()

    // 新增监控服务
    private let gpuMonitor = GPUMonitor()
    private let displayMonitor = DisplayMonitor()
    private let audioMonitor = AudioMonitor()
    private let usbMonitor = USBMonitor()
    private let diskIOMonitor = DiskIOMonitor()
    private let processMonitor = ProcessMonitor()
    private let bluetoothMonitor = BluetoothMonitor()
    private let applicationMonitor = ApplicationMonitor()

    private var cpuHistoryBuffer: RingBuffer<Double>
    private var memoryHistoryBuffer: RingBuffer<Double>
    private var downloadHistoryBuffer: RingBuffer<Double>
    private var uploadHistoryBuffer: RingBuffer<Double>
    private var diskReadHistoryBuffer: RingBuffer<Double>
    private var diskWriteHistoryBuffer: RingBuffer<Double>

    private var cancellables = Set<AnyCancellable>()
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

        fetchSystemInfo()
        startMonitoring()
    }

    private func fetchSystemInfo() {
        let processInfo = ProcessInfo.processInfo

        // 获取主机名
        let hostname = Host.current().localizedName ?? processInfo.hostName

        // 获取系统版本
        let osVersion = processInfo.operatingSystemVersionString

        // 获取内核版本
        var kernelVersion = "Darwin"
        var size: Int = 0
        sysctlbyname("kern.osrelease", nil, &size, nil, 0)
        if size > 0 {
            var release = [CChar](repeating: 0, count: size)
            sysctlbyname("kern.osrelease", &release, &size, nil, 0)
            kernelVersion = "Darwin \(String(cString: release))"
        }

        // 获取运行时间
        var boottime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        size = MemoryLayout<timeval>.stride
        sysctl(&mib, 2, &boottime, &size, nil, 0)
        let uptime = Date().timeIntervalSince1970 - Double(boottime.tv_sec)

        // 获取设备型号名称
        let modelName = getModelName()

        // 获取处理器名称
        let processorName = getProcessorBrandString()

        systemInfo = SystemInfo(
            hostname: hostname,
            osVersion: osVersion,
            kernelVersion: kernelVersion,
            uptime: uptime,
            modelName: modelName,
            processorName: processorName,
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

        // 转换模型标识符为友好名称
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
        } else if modelIdentifier.contains("Mac") {
            return "Mac Studio"
        }
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

        // Apple Silicon 没有 brand_string，尝试其他方式
        var chip = ""
        size = 0
        sysctlbyname("machdep.cpu.brand", nil, &size, nil, 0)
        if size > 0 {
            var brand = [CChar](repeating: 0, count: size)
            sysctlbyname("machdep.cpu.brand", &brand, &size, nil, 0)
            chip = String(cString: brand)
        }

        if chip.isEmpty {
            // 根据核心数猜测
            let coreCount = ProcessInfo.processInfo.processorCount
            if coreCount >= 20 {
                chip = "Apple M2 Ultra"
            } else if coreCount >= 12 {
                chip = "Apple M2 Pro"
            } else if coreCount >= 10 {
                chip = "Apple M1 Pro"
            } else if coreCount >= 8 {
                chip = "Apple M1"
            } else {
                chip = "Apple Silicon"
            }
        }

        return chip
    }

    private func startMonitoring() {
        // CPU 和网络: 每1秒刷新
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCPU()
                self?.updateNetwork()
            }
            .store(in: &cancellables)

        // 内存和磁盘I/O: 每2秒刷新
        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateMemory()
                self?.updateDiskIO()
            }
            .store(in: &cancellables)

        // 进程和应用: 每3秒刷新
        Timer.publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateProcesses()
                self?.updateApps()
            }
            .store(in: &cancellables)

        // GPU: 每5秒刷新 (静态信息，低频)
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateGPU()
            }
            .store(in: &cancellables)

        // 存储、电池、音频、USB、蓝牙: 每30秒刷新
        Timer.publish(every: 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateStorage()
                self?.updateBattery()
                self?.updateAudio()
                self?.updateUSB()
                self?.updateBluetooth()
            }
            .store(in: &cancellables)

        // 系统运行时间和显示器: 每60秒更新
        Timer.publish(every: 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchSystemInfo()
                self?.updateDisplay()
            }
            .store(in: &cancellables)

        // 初始更新
        updateCPU()
        updateMemory()
        updateStorage()
        updateNetwork()
        updateBattery()
        // 新增模块初始更新
        updateGPU()
        updateDisplay()
        updateAudio()
        updateUSB()
        updateDiskIO()
        updateProcesses()
        updateBluetooth()
        updateApps()
    }

    private func updateCPU() {
        cpuInfo = cpuMonitor.getCPUInfo()
        cpuHistoryBuffer.append(cpuInfo.usage)
        cpuHistory = cpuHistoryBuffer.toArray()
    }

    private func updateMemory() {
        memoryInfo = memoryMonitor.getMemoryInfo()
        memoryHistoryBuffer.append(memoryInfo.usagePercentage)
        memoryHistory = memoryHistoryBuffer.toArray()
    }

    private func updateStorage() {
        storageInfo = storageMonitor.getStorageInfo()
    }

    private func updateNetwork() {
        networkInfo = networkMonitor.getNetworkInfo()
        downloadHistoryBuffer.append(networkInfo.downloadSpeed)
        uploadHistoryBuffer.append(networkInfo.uploadSpeed)
        downloadHistory = downloadHistoryBuffer.toArray()
        uploadHistory = uploadHistoryBuffer.toArray()
    }

    private func updateBattery() {
        batteryInfo = batteryMonitor.getBatteryInfo()
    }

    // MARK: - 新增更新方法

    private func updateGPU() {
        gpuInfo = gpuMonitor.getGPUInfo()
    }

    private func updateDisplay() {
        displayInfo = displayMonitor.getDisplayInfo()
    }

    private func updateAudio() {
        audioDevices = audioMonitor.getAudioDevices()
    }

    private func updateUSB() {
        usbDevices = usbMonitor.getUSBDevices()
    }

    private func updateDiskIO() {
        diskIOInfo = diskIOMonitor.getDiskIOInfo()
        diskReadHistoryBuffer.append(diskIOInfo.readSpeed)
        diskWriteHistoryBuffer.append(diskIOInfo.writeSpeed)
        diskReadHistory = diskReadHistoryBuffer.toArray()
        diskWriteHistory = diskWriteHistoryBuffer.toArray()
    }

    private func updateProcesses() {
        topProcesses = processMonitor.getTopProcesses(limit: 10, sortBy: .cpu)
    }

    private func updateBluetooth() {
        bluetoothDevices = bluetoothMonitor.getBluetoothDevices()
    }

    private func updateApps() {
        topApps = applicationMonitor.getTopMemoryApps(limit: 10)
    }
}
