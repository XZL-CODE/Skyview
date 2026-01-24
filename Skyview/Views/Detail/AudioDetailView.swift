//
//  AudioDetailView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct AudioDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var outputDevices: [AudioDeviceInfo] {
        manager.audioDevices.filter { $0.deviceType == .output }
    }

    var inputDevices: [AudioDeviceInfo] {
        manager.audioDevices.filter { $0.deviceType == .input }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "音频设备",
                    subtitle: "\(manager.audioDevices.count) 个设备",
                    icon: "speaker.wave.3",
                    gradient: [.audioGradientStart, .audioGradientEnd]
                )

                // 输出设备
                if !outputDevices.isEmpty {
                    AudioSectionView(title: "输出设备", icon: "speaker.wave.2", devices: outputDevices)
                }

                // 输入设备
                if !inputDevices.isEmpty {
                    AudioSectionView(title: "输入设备", icon: "mic", devices: inputDevices)
                }

                if manager.audioDevices.isEmpty {
                    EmptyStateView(
                        icon: "speaker.slash",
                        title: "未检测到音频设备",
                        message: "无法获取音频设备信息"
                    )
                }
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct AudioSectionView: View {
    let title: String
    let icon: String
    let devices: [AudioDeviceInfo]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.audioGradientStart)

                Text(title)
                    .font(.headline)

                Spacer()

                Text("\(devices.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }

            ForEach(devices) { device in
                AudioDeviceCardView(device: device)
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct AudioDeviceCardView: View {
    let device: AudioDeviceInfo

    var body: some View {
        HStack(spacing: 16) {
            // 图标
            ZStack {
                Circle()
                    .fill(device.isDefault ? Color.audioGradientStart.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: device.deviceType == .output ? "speaker.wave.2.fill" : "mic.fill")
                    .font(.system(size: 18))
                    .foregroundColor(device.isDefault ? .audioGradientStart : .gray)
            }

            // 设备信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(device.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if device.isDefault {
                        TagView(text: "默认", color: .audioGradientStart)
                    }
                }

                Text(device.manufacturer)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 音量指示器 (仅输出设备)
            if let volume = device.volume, device.deviceType == .output {
                VolumeIndicator(volume: volume)
            }

            // 详细信息
            VStack(alignment: .trailing, spacing: 4) {
                Text(device.sampleRateFormatted)
                    .font(.system(size: 12, weight: .medium, design: .rounded))

                Text("\(device.channelCount) 声道")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct VolumeIndicator: View {
    let volume: Float

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Float(i) / 5 < volume ? Color.audioGradientStart : Color.gray.opacity(0.2))
                    .frame(width: 4, height: CGFloat(8 + i * 3))
            }
        }
    }
}

#Preview {
    AudioDetailView(manager: SystemInfoManager())
        .frame(width: 600, height: 700)
}
