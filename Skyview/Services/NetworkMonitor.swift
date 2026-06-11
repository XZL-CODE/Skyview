//
//  NetworkMonitor.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import Darwin
import SystemConfiguration

nonisolated class NetworkMonitor {
    private var previousBytesReceived: UInt64 = 0
    private var previousBytesSent: UInt64 = 0
    private var previousTimestamp: Date?

    func getNetworkInfo() -> NetworkInfo {
        let (bytesReceived, bytesSent, interfaceName) = getNetworkBytes()
        let ipAddress = getIPAddress(for: interfaceName)

        let now = Date()
        var downloadSpeed: Double = 0
        var uploadSpeed: Double = 0

        if let previousTime = previousTimestamp {
            let timeDiff = now.timeIntervalSince(previousTime)
            if timeDiff > 0 {
                let receivedDiff = bytesReceived > previousBytesReceived ?
                    Double(bytesReceived - previousBytesReceived) : 0
                let sentDiff = bytesSent > previousBytesSent ?
                    Double(bytesSent - previousBytesSent) : 0

                downloadSpeed = receivedDiff / timeDiff
                uploadSpeed = sentDiff / timeDiff
            }
        }

        previousBytesReceived = bytesReceived
        previousBytesSent = bytesSent
        previousTimestamp = now

        return NetworkInfo(
            bytesReceived: bytesReceived,
            bytesSent: bytesSent,
            downloadSpeed: downloadSpeed,
            uploadSpeed: uploadSpeed,
            activeInterface: interfaceName,
            ipAddress: ipAddress
        )
    }

    private func getNetworkBytes() -> (received: UInt64, sent: UInt64, interface: String) {
        // 通过 NET_RT_IFLIST2 读取 64 位流量计数器
        // (getifaddrs 的 if_data 计数器是 32 位，4GB 即回绕，累计流量会算错)
        var mib: [Int32] = [CTL_NET, PF_ROUTE, 0, 0, NET_RT_IFLIST2, 0]
        var len = 0
        guard sysctl(&mib, u_int(mib.count), nil, &len, nil, 0) == 0, len > 0 else {
            return (0, 0, "en0")
        }

        var buffer = [UInt8](repeating: 0, count: len)
        guard sysctl(&mib, u_int(mib.count), &buffer, &len, nil, 0) == 0 else {
            return (0, 0, "en0")
        }

        var totalReceived: UInt64 = 0
        var totalSent: UInt64 = 0
        var activeInterface = "en0"
        var maxBytes: UInt64 = 0

        buffer.withUnsafeBytes { raw in
            var offset = 0
            while offset + MemoryLayout<if_msghdr>.size <= len {
                // 消息边界不保证按 8 字节对齐，用逐字节拷贝代替直接 load
                var header = if_msghdr()
                withUnsafeMutableBytes(of: &header) { dst in
                    dst.copyMemory(from: UnsafeRawBufferPointer(rebasing: raw[offset..<offset + MemoryLayout<if_msghdr>.size]))
                }

                let msgLen = Int(header.ifm_msglen)
                guard msgLen > 0 else { break }

                if Int32(header.ifm_type) == RTM_IFINFO2,
                   offset + MemoryLayout<if_msghdr2>.size <= len {
                    var header2 = if_msghdr2()
                    withUnsafeMutableBytes(of: &header2) { dst in
                        dst.copyMemory(from: UnsafeRawBufferPointer(rebasing: raw[offset..<offset + MemoryLayout<if_msghdr2>.size]))
                    }

                    var nameBuffer = [CChar](repeating: 0, count: Int(IF_NAMESIZE) + 1)
                    if if_indextoname(UInt32(header2.ifm_index), &nameBuffer) != nil {
                        let name = String(cString: nameBuffer)
                        // 只统计 en* 物理接口，bridge 等虚拟口会重复计数成员流量
                        if name.hasPrefix("en") {
                            let received = header2.ifm_data.ifi_ibytes
                            let sent = header2.ifm_data.ifi_obytes
                            totalReceived += received
                            totalSent += sent

                            if received > maxBytes {
                                maxBytes = received
                                activeInterface = name
                            }
                        }
                    }
                }

                offset += msgLen
            }
        }

        return (totalReceived, totalSent, activeInterface)
    }

    private func getIPAddress(for interfaceName: String) -> String? {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return nil
        }
        defer { freeifaddrs(ifaddr) }

        var ptr = firstAddr
        repeat {
            let interface = ptr.pointee
            let name = String(cString: interface.ifa_name)

            if name == interfaceName {
                let family = interface.ifa_addr.pointee.sa_family
                if family == UInt8(AF_INET) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        0,
                        NI_NUMERICHOST
                    )
                    return String(cString: hostname)
                }
            }

            if let next = interface.ifa_next {
                ptr = next
            } else {
                break
            }
        } while true

        return nil
    }
}
