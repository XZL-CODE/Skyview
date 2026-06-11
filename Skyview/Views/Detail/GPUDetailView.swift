//
//  GPUDetailView.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct GPUDetailView: View {
    @ObservedObject var manager: SystemInfoManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                DetailHeaderView(
                    title: "GPU 监控",
                    subtitle: manager.gpuInfo.first?.name ?? "未检测到 GPU",
                    icon: "rectangle.3.group",
                    gradient: [.gpuGradientStart, .gpuGradientEnd]
                )

                // GPU 列表
                ForEach(manager.gpuInfo) { gpu in
                    GPUCardView(gpu: gpu)
                }

                if manager.gpuInfo.isEmpty {
                    EmptyStateView(
                        icon: "rectangle.3.group",
                        title: "未检测到 GPU",
                        message: "无法获取 GPU 信息"
                    )
                }
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct GPUCardView: View {
    let gpu: GPUInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // GPU 名称和标签
            HStack {
                Image(systemName: "rectangle.3.group.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.gpuGradientStart, .gpuGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(gpu.name)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(gpu.architecture)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 标签
                HStack(spacing: 8) {
                    if gpu.isLowPower {
                        TagView(text: "低功耗", color: .green)
                    }
                    if gpu.isRemovable {
                        TagView(text: "eGPU", color: .orange)
                    }
                    if gpu.supportsRaytracing {
                        TagView(text: "光追", color: .purple)
                    }
                }
            }

            Divider()

            // Metal 信息
            HStack(spacing: 16) {
                MetalBadge(version: gpu.metalVersion, family: gpu.gpuFamily)
                Spacer()
            }

            // 主要规格
            VStack(alignment: .leading, spacing: 12) {
                Text("主要规格")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    GPUSpecCard(
                        icon: "memorychip",
                        label: "推荐显存",
                        value: gpu.recommendedMemoryFormatted,
                        color: .blue
                    )
                    GPUSpecCard(
                        icon: "square.grid.3x3",
                        label: "最大纹理",
                        value: gpu.maxTextureDescription,
                        color: .purple
                    )
                    GPUSpecCard(
                        icon: "cpu",
                        label: "线程组",
                        value: "\(gpu.maxThreadsPerGroup)",
                        color: .orange
                    )
                }
            }

            // 详细规格
            VStack(alignment: .leading, spacing: 12) {
                Text("详细规格")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    GPUInfoRow(label: "最大缓冲区", value: gpu.maxBufferLengthFormatted)
                    GPUInfoRow(label: "线程组内存", value: gpu.maxThreadgroupMemoryFormatted)
                    GPUInfoRow(label: "2D 纹理上限", value: "\(gpu.maxTextureSize2D) x \(gpu.maxTextureSize2D)")
                    GPUInfoRow(label: "3D 纹理上限", value: "\(gpu.maxTextureSize3D)³")
                    GPUInfoRow(label: "Cube 纹理", value: "\(gpu.maxTextureSizeCube)")
                    GPUInfoRow(label: "Registry ID", value: String(format: "0x%llX", gpu.registryID))
                }
            }

            Divider()

            // Metal 功能支持
            VStack(alignment: .leading, spacing: 12) {
                Text("Metal 功能支持")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    FeatureIndicator(name: "光线追踪", supported: gpu.supportsRaytracing)
                    FeatureIndicator(name: "动态库", supported: gpu.supportsDynamicLibraries)
                    FeatureIndicator(name: "函数指针", supported: gpu.supportsFunctionPointers)
                    FeatureIndicator(name: "重心坐标", supported: gpu.supportsBarycentricCoords)
                    FeatureIndicator(name: "32位浮点过滤", supported: gpu.supports32BitFloatFiltering)
                    FeatureIndicator(name: "32位MSAA", supported: gpu.supports32BitMSAA)
                    FeatureIndicator(name: "BC纹理压缩", supported: gpu.supportsBCTextureCompression)
                    FeatureIndicator(name: "Pull Model", supported: gpu.supportsPullModelInterpolation)
                    FeatureIndicator(name: "纹理LOD查询", supported: gpu.supportsQueryTextureLOD)
                }
            }

            // 设备类型
            HStack {
                Text("设备类型")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(gpu.isHeadless ? "计算专用 (Headless)" : "图形 + 计算")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

struct MetalBadge: View {
    let version: String
    let family: String

    var body: some View {
        HStack(spacing: 12) {
            // Metal 版本徽章
            HStack(spacing: 6) {
                Image(systemName: "seal.fill")
                    .foregroundColor(.blue)
                Text(version)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.15))
            .cornerRadius(8)

            // GPU 家族徽章
            Text(family)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

struct GPUSpecCard: View {
    let icon: String
    let label: LocalizedStringKey
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}

struct GPUInfoRow: View {
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TagView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

struct FeatureIndicator: View {
    let name: String
    let supported: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: supported ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(supported ? .green : .gray)

            Text(name)
                .font(.caption)
                .foregroundColor(supported ? .primary : .secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(6)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: LocalizedStringKey
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

#Preview {
    GPUDetailView(manager: SystemInfoManager())
        .frame(width: 700, height: 900)
}
