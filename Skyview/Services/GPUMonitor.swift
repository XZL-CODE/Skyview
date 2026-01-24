//
//  GPUMonitor.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import Metal

class GPUMonitor {
    func getGPUInfo() -> [GPUInfo] {
        var gpuList: [GPUInfo] = []

        let devices = MTLCopyAllDevices()

        for device in devices {
            let info = createGPUInfo(from: device)
            gpuList.append(info)
        }

        if gpuList.isEmpty {
            // 如果没有找到 GPU，尝试获取默认设备
            if let defaultDevice = MTLCreateSystemDefaultDevice() {
                let info = createGPUInfo(from: defaultDevice)
                gpuList.append(info)
            }
        }

        return gpuList
    }

    private func createGPUInfo(from device: MTLDevice) -> GPUInfo {
        let maxThreads = device.maxThreadsPerThreadgroup

        return GPUInfo(
            name: device.name,
            isLowPower: device.isLowPower,
            isRemovable: device.isRemovable,
            isHeadless: device.isHeadless,
            recommendedMemory: UInt64(device.recommendedMaxWorkingSetSize),
            maxThreadsPerGroup: maxThreads.width,
            supportsRaytracing: device.supportsRaytracing,
            registryID: device.registryID,
            maxBufferLength: UInt64(device.maxBufferLength),
            maxTextureSize2D: getMaxTextureSize2D(device),
            maxTextureSize3D: getMaxTextureSize3D(device),
            maxTextureSizeCube: getMaxTextureSizeCube(device),
            maxThreadgroupMemory: UInt64(device.maxThreadgroupMemoryLength),
            maxThreadsPerThreadgroup: (maxThreads.width, maxThreads.height, maxThreads.depth),
            supportsBarycentricCoords: device.supportsShaderBarycentricCoordinates,
            supportsDynamicLibraries: device.supportsDynamicLibraries,
            supportsFunctionPointers: device.supportsFunctionPointers,
            supportsShaderBarycentricCoordinates: device.supportsShaderBarycentricCoordinates,
            supports32BitFloatFiltering: device.supports32BitFloatFiltering,
            supports32BitMSAA: device.supports32BitMSAA,
            supportsBCTextureCompression: device.supportsBCTextureCompression,
            supportsPullModelInterpolation: device.supportsPullModelInterpolation,
            supportsQueryTextureLOD: device.supportsQueryTextureLOD,
            gpuFamily: getGPUFamily(device),
            metalVersion: getMetalVersion(device),
            architecture: getArchitecture(device)
        )
    }

    private func getMaxTextureSize2D(_ device: MTLDevice) -> Int {
        // 检测支持的 GPU 家族来确定纹理大小
        if device.supportsFamily(.apple7) || device.supportsFamily(.apple8) {
            return 16384
        } else if device.supportsFamily(.apple6) {
            return 16384
        } else if device.supportsFamily(.apple5) {
            return 16384
        } else if device.supportsFamily(.apple4) {
            return 16384
        } else if device.supportsFamily(.mac2) {
            return 16384
        }
        return 8192
    }

    private func getMaxTextureSize3D(_ device: MTLDevice) -> Int {
        if device.supportsFamily(.apple7) || device.supportsFamily(.apple8) {
            return 2048
        }
        return 2048
    }

    private func getMaxTextureSizeCube(_ device: MTLDevice) -> Int {
        return getMaxTextureSize2D(device)
    }

    private func getGPUFamily(_ device: MTLDevice) -> String {
        // Apple GPU 家族检测
        if device.supportsFamily(.apple9) {
            return "Apple 9 (M3系列)"
        } else if device.supportsFamily(.apple8) {
            return "Apple 8 (M2系列)"
        } else if device.supportsFamily(.apple7) {
            return "Apple 7 (M1系列)"
        } else if device.supportsFamily(.apple6) {
            return "Apple 6 (A14)"
        } else if device.supportsFamily(.apple5) {
            return "Apple 5 (A12/A13)"
        } else if device.supportsFamily(.apple4) {
            return "Apple 4 (A11)"
        } else if device.supportsFamily(.apple3) {
            return "Apple 3 (A9/A10)"
        }

        // Mac GPU 家族检测
        if device.supportsFamily(.mac2) {
            return "Mac 2 (Intel/AMD)"
        } else if device.supportsFamily(.common3) {
            return "Common 3"
        }

        return "Unknown"
    }

    private func getMetalVersion(_ device: MTLDevice) -> String {
        // 检测 Metal 版本支持
        if device.supportsFamily(.metal3) {
            return "Metal 3"
        }

        // 基于 GPU 家族推断 Metal 版本
        if device.supportsFamily(.apple7) || device.supportsFamily(.apple8) || device.supportsFamily(.apple9) {
            return "Metal 3"
        } else if device.supportsFamily(.apple6) {
            return "Metal 2.4"
        } else if device.supportsFamily(.mac2) {
            return "Metal 2"
        }

        return "Metal 2"
    }

    private func getArchitecture(_ device: MTLDevice) -> String {
        let name = device.name.lowercased()

        if name.contains("m3") {
            return "Apple GPU (3nm)"
        } else if name.contains("m2") {
            return "Apple GPU (5nm)"
        } else if name.contains("m1") {
            return "Apple GPU (5nm)"
        } else if name.contains("apple") {
            return "Apple GPU"
        } else if name.contains("amd") || name.contains("radeon") {
            return "AMD RDNA/GCN"
        } else if name.contains("intel") {
            return "Intel Integrated"
        } else if name.contains("nvidia") || name.contains("geforce") {
            return "NVIDIA"
        }

        return "Unknown"
    }
}
