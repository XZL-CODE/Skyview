//
//  NetworkMonitor.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import Darwin
import SystemConfiguration

class NetworkMonitor {
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
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return (0, 0, "unknown")
        }
        defer { freeifaddrs(ifaddr) }

        var totalReceived: UInt64 = 0
        var totalSent: UInt64 = 0
        var activeInterface = "en0"

        var ptr = firstAddr
        repeat {
            let interface = ptr.pointee
            let name = String(cString: interface.ifa_name)

            // 只统计物理网络接口
            if name.hasPrefix("en") || name.hasPrefix("bridge") {
                if let data = interface.ifa_data {
                    let networkData = data.assumingMemoryBound(to: if_data.self).pointee
                    totalReceived += UInt64(networkData.ifi_ibytes)
                    totalSent += UInt64(networkData.ifi_obytes)

                    // 找到主要活跃接口
                    if networkData.ifi_ibytes > 0 && name.hasPrefix("en") {
                        activeInterface = name
                    }
                }
            }

            if let next = interface.ifa_next {
                ptr = next
            } else {
                break
            }
        } while true

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
