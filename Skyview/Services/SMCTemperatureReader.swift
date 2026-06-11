//
//  SMCTemperatureReader.swift
//  Skyview
//
//  Created by xzl on 2026/6/10.
//

import Foundation
import IOKit

/// 通过 AppleSMC 用户客户端读取 CPU 温度传感器。
/// 连接与传感器 key 列表只初始化一次; 之后每次调用仅读取匹配 key 的当前值。
/// 在采集队列上同步调用, 不涉及主线程。
nonisolated final class SMCTemperatureReader {

    // MARK: - SMC 协议结构 (内存布局必须与 AppleSMC 内核驱动一致, 总长 80 字节)

    private struct SMCVersion {
        var major: UInt8 = 0
        var minor: UInt8 = 0
        var build: UInt8 = 0
        var reserved: UInt8 = 0
        var release: UInt16 = 0
    }

    private struct SMCPLimitData {
        var version: UInt16 = 0
        var length: UInt16 = 0
        var cpuPLimit: UInt32 = 0
        var gpuPLimit: UInt32 = 0
        var memPLimit: UInt32 = 0
    }

    private struct SMCKeyInfoData {
        var dataSize: UInt32 = 0
        var dataType: UInt32 = 0
        var dataAttributes: UInt8 = 0
        // C 端该结构按 4 字节对齐补到 12 字节, Swift 嵌套结构不带尾部填充, 需手工补齐,
        // 否则整个 SMCParamStruct 变成 76 字节, 内核会拒绝 (kIOReturnBadArgument)
        var padding: (UInt8, UInt8, UInt8) = (0, 0, 0)
    }

    private struct SMCParamStruct {
        var key: UInt32 = 0
        var vers = SMCVersion()
        var pLimitData = SMCPLimitData()
        var keyInfo = SMCKeyInfoData()
        var result: UInt8 = 0
        var status: UInt8 = 0
        var data8: UInt8 = 0
        var data32: UInt32 = 0
        var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) =
            (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    }

    private enum SMCCommand: UInt8 {
        case readKey = 5
        case getKeyFromIndex = 8
        case getKeyInfo = 9
    }

    private static let kSMCHandleYPCEvent: UInt32 = 2

    // MARK: - 状态

    private var connection: io_connect_t = 0
    /// 首次调用时解析出的温度传感器 key 及其数据类型
    private var sensorKeys: [(key: UInt32, dataType: String, dataSize: UInt32)] = []
    private var initialized = false
    private var unavailable = false

    deinit {
        if connection != 0 {
            IOServiceClose(connection)
        }
    }

    // MARK: - 对外 API

    /// 所有 CPU 温度传感器的平均值 (°C); SMC 不可用 (如虚拟机) 时返回 nil
    func cpuTemperature() -> Double? {
        if !initialized {
            initialize()
        }
        guard !unavailable, !sensorKeys.isEmpty else { return nil }

        var values: [Double] = []
        for sensor in sensorKeys {
            if let value = readValue(key: sensor.key, dataType: sensor.dataType, dataSize: sensor.dataSize),
               value > 10, value < 120 {
                values.append(value)
            }
        }

        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    // MARK: - 初始化: 建连接 + 枚举温度 key

    private func initialize() {
        initialized = true

        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != 0 else {
            unavailable = true
            return
        }
        defer { IOObjectRelease(service) }

        guard IOServiceOpen(service, mach_task_self_, 0, &connection) == kIOReturnSuccess else {
            connection = 0
            unavailable = true
            return
        }

        // "#KEY" 给出 SMC key 总数, 逐个枚举筛出 CPU 温度传感器:
        //   Apple Silicon: Tp* (性能核) / Te* (能效核), flt 类型
        //   Intel: TC* (TC0P 等), sp78/flt 类型
        guard let keyCountValue = readValue(keyName: "#KEY"), keyCountValue > 0 else {
            unavailable = true
            return
        }

        let keyCount = UInt32(keyCountValue)
        for index in 0..<keyCount {
            guard let key = keyAtIndex(index) else { continue }
            let name = keyToString(key)

            guard name.hasPrefix("Tp") || name.hasPrefix("Te") || name.hasPrefix("TC") else { continue }

            guard let info = keyInfo(key: key) else { continue }
            let dataType = typeToString(info.dataType)
            guard dataType == "flt " || dataType == "sp78" else { continue }

            sensorKeys.append((key: key, dataType: dataType, dataSize: info.dataSize))
        }

        if sensorKeys.isEmpty {
            unavailable = true
        }
    }

    // MARK: - SMC 调用

    private func callSMC(input: inout SMCParamStruct) -> SMCParamStruct? {
        var output = SMCParamStruct()
        var outputSize = MemoryLayout<SMCParamStruct>.stride

        let result = IOConnectCallStructMethod(
            connection,
            Self.kSMCHandleYPCEvent,
            &input,
            MemoryLayout<SMCParamStruct>.stride,
            &output,
            &outputSize
        )

        guard result == kIOReturnSuccess, output.result == 0 else { return nil }
        return output
    }

    private func keyInfo(key: UInt32) -> SMCKeyInfoData? {
        var input = SMCParamStruct()
        input.key = key
        input.data8 = SMCCommand.getKeyInfo.rawValue
        return callSMC(input: &input)?.keyInfo
    }

    private func keyAtIndex(_ index: UInt32) -> UInt32? {
        var input = SMCParamStruct()
        input.data32 = index
        input.data8 = SMCCommand.getKeyFromIndex.rawValue
        return callSMC(input: &input)?.key
    }

    private func readValue(keyName: String) -> Double? {
        let key = stringToKey(keyName)
        guard let info = keyInfo(key: key) else { return nil }
        return readValue(key: key, dataType: typeToString(info.dataType), dataSize: info.dataSize)
    }

    private func readValue(key: UInt32, dataType: String, dataSize: UInt32) -> Double? {
        var input = SMCParamStruct()
        input.key = key
        input.keyInfo.dataSize = dataSize
        input.data8 = SMCCommand.readKey.rawValue

        guard let output = callSMC(input: &input) else { return nil }

        return withUnsafeBytes(of: output.bytes) { raw -> Double? in
            switch dataType {
            case "flt ":
                // 小端 IEEE float
                guard dataSize >= 4 else { return nil }
                let value = raw.loadUnaligned(fromByteOffset: 0, as: Float32.self)
                return Double(value)
            case "sp78":
                // 大端定点数: 高字节整数部分带符号, /256 得到小数
                guard dataSize >= 2 else { return nil }
                let rawValue = Int16(raw[0]) << 8 | Int16(raw[1])
                return Double(rawValue) / 256.0
            case "ui8 ":
                return Double(raw[0])
            case "ui16":
                return Double(UInt16(raw[0]) << 8 | UInt16(raw[1]))
            case "ui32":
                let value = (UInt32(raw[0]) << 24) | (UInt32(raw[1]) << 16)
                    | (UInt32(raw[2]) << 8) | UInt32(raw[3])
                return Double(value)
            default:
                return nil
            }
        }
    }

    // MARK: - FourCC 转换

    private func stringToKey(_ name: String) -> UInt32 {
        var result: UInt32 = 0
        for char in name.utf8.prefix(4) {
            result = result << 8 | UInt32(char)
        }
        return result
    }

    private func keyToString(_ key: UInt32) -> String {
        let bytes = [
            UInt8((key >> 24) & 0xFF),
            UInt8((key >> 16) & 0xFF),
            UInt8((key >> 8) & 0xFF),
            UInt8(key & 0xFF),
        ]
        return String(bytes: bytes, encoding: .ascii) ?? ""
    }

    private func typeToString(_ type: UInt32) -> String {
        keyToString(type)
    }
}
