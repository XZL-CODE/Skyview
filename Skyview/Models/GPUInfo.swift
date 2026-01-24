//
//  GPUInfo.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import Metal

struct GPUInfo: Identifiable {
    let id = UUID()
    var name: String
    var isLowPower: Bool
    var isRemovable: Bool
    var isHeadless: Bool
    var recommendedMemory: UInt64
    var maxThreadsPerGroup: Int
    var supportsRaytracing: Bool
    var registryID: UInt64

    // 新增详细信息
    var maxBufferLength: UInt64              // 最大缓冲区长度
    var maxTextureSize2D: Int                // 2D 纹理最大尺寸
    var maxTextureSize3D: Int                // 3D 纹理最大尺寸
    var maxTextureSizeCube: Int              // Cube 纹理最大尺寸
    var maxThreadgroupMemory: UInt64         // 线程组最大内存
    var maxThreadsPerThreadgroup: (width: Int, height: Int, depth: Int)

    // Metal 功能支持
    var supportsBarycentricCoords: Bool      // 重心坐标
    var supportsDynamicLibraries: Bool       // 动态库
    var supportsFunctionPointers: Bool       // 函数指针
    var supportsShaderBarycentricCoordinates: Bool
    var supports32BitFloatFiltering: Bool    // 32位浮点过滤
    var supports32BitMSAA: Bool              // 32位 MSAA
    var supportsBCTextureCompression: Bool   // BC 纹理压缩
    var supportsPullModelInterpolation: Bool // Pull Model 插值
    var supportsQueryTextureLOD: Bool        // 纹理 LOD 查询

    // GPU 家族
    var gpuFamily: String
    var metalVersion: String

    // 架构信息
    var architecture: String

    var recommendedMemoryFormatted: String {
        ByteFormatter.format(recommendedMemory)
    }

    var maxBufferLengthFormatted: String {
        ByteFormatter.format(maxBufferLength)
    }

    var maxThreadgroupMemoryFormatted: String {
        ByteFormatter.format(maxThreadgroupMemory)
    }

    var maxTextureDescription: String {
        "\(maxTextureSize2D) x \(maxTextureSize2D)"
    }

    var threadsPerGroupDescription: String {
        "\(maxThreadsPerThreadgroup.width) x \(maxThreadsPerThreadgroup.height) x \(maxThreadsPerThreadgroup.depth)"
    }

    static var placeholder: GPUInfo {
        GPUInfo(
            name: "Apple M1",
            isLowPower: false,
            isRemovable: false,
            isHeadless: false,
            recommendedMemory: 8 * 1024 * 1024 * 1024,
            maxThreadsPerGroup: 1024,
            supportsRaytracing: true,
            registryID: 0,
            maxBufferLength: 0,
            maxTextureSize2D: 16384,
            maxTextureSize3D: 2048,
            maxTextureSizeCube: 16384,
            maxThreadgroupMemory: 32768,
            maxThreadsPerThreadgroup: (1024, 1024, 1024),
            supportsBarycentricCoords: true,
            supportsDynamicLibraries: true,
            supportsFunctionPointers: true,
            supportsShaderBarycentricCoordinates: true,
            supports32BitFloatFiltering: true,
            supports32BitMSAA: true,
            supportsBCTextureCompression: true,
            supportsPullModelInterpolation: true,
            supportsQueryTextureLOD: true,
            gpuFamily: "Apple 7",
            metalVersion: "Metal 3",
            architecture: "Apple GPU"
        )
    }
}
