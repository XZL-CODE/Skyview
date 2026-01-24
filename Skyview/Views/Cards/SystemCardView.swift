//
//  SystemCardView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct SystemCardView: View {
    let systemInfo: SystemInfo

    var body: some View {
        CardContainerView(
            title: "系统",
            iconName: "desktopcomputer",
            iconColor: .systemGradientStart
        ) {
            VStack(spacing: 16) {
                // 设备图标
                Image(systemName: getDeviceIcon())
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.systemGradientStart, .systemGradientEnd],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .padding(.vertical, 8)

                // 设备名称
                Text(systemInfo.hostname)
                    .font(.headline)

                // 详细信息
                VStack(spacing: 8) {
                    InfoRowView(
                        label: "型号",
                        value: systemInfo.modelName
                    )
                    InfoRowView(
                        label: "处理器",
                        value: truncateProcessorName(systemInfo.processorName)
                    )
                    InfoRowView(
                        label: "核心数",
                        value: "\(systemInfo.processorCount)"
                    )
                    InfoRowView(
                        label: "内存",
                        value: ByteFormatter.format(systemInfo.physicalMemory, decimals: 0)
                    )

                    Divider()
                        .padding(.vertical, 4)

                    InfoRowView(
                        label: "系统版本",
                        value: formatOSVersion(systemInfo.osVersion)
                    )
                    InfoRowView(
                        label: "运行时间",
                        value: systemInfo.uptime.formatUptime()
                    )
                }
            }
        }
    }

    private func getDeviceIcon() -> String {
        let model = systemInfo.modelName.lowercased()
        if model.contains("macbook") {
            return "laptopcomputer"
        } else if model.contains("imac") {
            return "desktopcomputer"
        } else if model.contains("mac mini") {
            return "macmini"
        } else if model.contains("mac pro") {
            return "macpro.gen3"
        } else if model.contains("mac studio") {
            return "macstudio"
        }
        return "desktopcomputer"
    }

    private func truncateProcessorName(_ name: String) -> String {
        // 简化处理器名称以适应卡片宽度
        var result = name
            .replacingOccurrences(of: "(R)", with: "")
            .replacingOccurrences(of: "(TM)", with: "")
            .replacingOccurrences(of: "CPU", with: "")
            .trimmingCharacters(in: .whitespaces)

        // 如果太长，截断
        if result.count > 20 {
            if let range = result.range(of: "@") {
                result = String(result[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
        }

        return result
    }

    private func formatOSVersion(_ version: String) -> String {
        // 提取版本号部分
        if let range = version.range(of: "Version ") {
            let afterVersion = version[range.upperBound...]
            if let endRange = afterVersion.firstIndex(of: " ") {
                return "macOS " + String(afterVersion[..<endRange])
            }
        }
        return version
    }
}

#Preview {
    SystemCardView(systemInfo: SystemInfo.placeholder)
        .frame(width: 220)
        .padding()
}
