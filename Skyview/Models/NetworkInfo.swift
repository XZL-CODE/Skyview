//
//  NetworkInfo.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation

struct NetworkInfo {
    var bytesReceived: UInt64       // 总接收字节
    var bytesSent: UInt64           // 总发送字节
    var downloadSpeed: Double       // 下载速度 (bytes/s)
    var uploadSpeed: Double         // 上传速度 (bytes/s)
    var activeInterface: String     // 活跃接口名称
    var ipAddress: String?          // IP地址

    static var placeholder: NetworkInfo {
        NetworkInfo(
            bytesReceived: 125 * 1024 * 1024,
            bytesSent: 45 * 1024 * 1024,
            downloadSpeed: 1.5 * 1024 * 1024,
            uploadSpeed: 0.5 * 1024 * 1024,
            activeInterface: "en0",
            ipAddress: "192.168.1.100"
        )
    }
}
