//
//  AudioMonitor.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import CoreAudio
import AudioToolbox

nonisolated class AudioMonitor {
    func getAudioDevices() -> [AudioDeviceInfo] {
        var devices: [AudioDeviceInfo] = []

        // 获取设备数量
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize
        )

        guard status == noErr else { return devices }

        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceIDs
        )

        guard status == noErr else { return devices }

        // 获取默认设备
        let defaultOutputID = getDefaultDevice(forInput: false)
        let defaultInputID = getDefaultDevice(forInput: true)

        for deviceID in deviceIDs {
            let name = getDeviceName(deviceID)
            let manufacturer = getDeviceManufacturer(deviceID)
            let hasOutput = hasStreams(deviceID, forInput: false)
            let hasInput = hasStreams(deviceID, forInput: true)
            let sampleRate = getSampleRate(deviceID)
            let channelCount = getChannelCount(deviceID, forInput: false)

            if hasOutput {
                let isDefault = deviceID == defaultOutputID
                let volume = getVolume(deviceID, forInput: false)

                let info = AudioDeviceInfo(
                    id: deviceID,
                    name: name,
                    deviceType: .output,
                    sampleRate: sampleRate,
                    channelCount: channelCount,
                    isDefault: isDefault,
                    volume: volume,
                    manufacturer: manufacturer
                )
                devices.append(info)
            }

            if hasInput {
                let isDefault = deviceID == defaultInputID
                let inputChannels = getChannelCount(deviceID, forInput: true)

                let info = AudioDeviceInfo(
                    id: deviceID,
                    name: name,
                    deviceType: .input,
                    sampleRate: sampleRate,
                    channelCount: inputChannels,
                    isDefault: isDefault,
                    volume: nil,
                    manufacturer: manufacturer
                )
                devices.append(info)
            }
        }

        return devices
    }

    private func getDefaultDevice(forInput: Bool) -> AudioDeviceID {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: forInput ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID: AudioDeviceID = 0
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)

        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceID
        )

        return deviceID
    }

    private func getDeviceName(_ deviceID: AudioDeviceID) -> String {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var name: Unmanaged<CFString>?
        var dataSize = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)

        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &name
        )

        guard status == noErr, let cfName = name?.takeRetainedValue() else {
            return "未知设备"
        }
        return cfName as String
    }

    private func getDeviceManufacturer(_ deviceID: AudioDeviceID) -> String {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceManufacturerCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var manufacturer: Unmanaged<CFString>?
        var dataSize = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)

        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &manufacturer
        )

        guard status == noErr, let cfManufacturer = manufacturer?.takeRetainedValue() else {
            return "未知"
        }
        return cfManufacturer as String
    }

    private func hasStreams(_ deviceID: AudioDeviceID, forInput: Bool) -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: forInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &dataSize)

        return status == noErr && dataSize > 0
    }

    private func getSampleRate(_ deviceID: AudioDeviceID) -> Double {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyNominalSampleRate,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var sampleRate: Float64 = 0
        var dataSize = UInt32(MemoryLayout<Float64>.size)

        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &sampleRate
        )

        return status == noErr ? sampleRate : 44100
    }

    private func getChannelCount(_ deviceID: AudioDeviceID, forInput: Bool) -> Int {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: forInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &dataSize)

        guard status == noErr && dataSize > 0 else { return 0 }

        // Allocate raw bytes, not AudioBufferList count
        let bufferListPtr = UnsafeMutableRawPointer.allocate(byteCount: Int(dataSize), alignment: MemoryLayout<AudioBufferList>.alignment)
        defer { bufferListPtr.deallocate() }

        status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &dataSize, bufferListPtr)

        guard status == noErr else { return 0 }

        let bufferList = bufferListPtr.assumingMemoryBound(to: AudioBufferList.self).pointee
        var channelCount: UInt32 = 0

        // Safe iteration over audio buffers
        withUnsafePointer(to: bufferList.mBuffers) { buffersPtr in
            for i in 0..<Int(bufferList.mNumberBuffers) {
                let buffer = buffersPtr.advanced(by: i).pointee
                channelCount += buffer.mNumberChannels
            }
        }

        return Int(channelCount)
    }

    private func getVolume(_ deviceID: AudioDeviceID, forInput: Bool) -> Float? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: forInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var volume: Float32 = 0
        var dataSize = UInt32(MemoryLayout<Float32>.size)

        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &volume
        )

        return status == noErr ? volume : nil
    }
}
