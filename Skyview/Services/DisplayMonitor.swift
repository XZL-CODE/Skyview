//
//  DisplayMonitor.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import Foundation
import AppKit
import CoreGraphics

class DisplayMonitor {
    func getDisplayInfo() -> [DisplayInfo] {
        var displays: [DisplayInfo] = []

        for (index, screen) in NSScreen.screens.enumerated() {
            let frame = screen.frame
            let deviceDescription = screen.deviceDescription
            let scaleFactor = screen.backingScaleFactor

            // 获取刷新率
            var refreshRate = 60
            if let displayID = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID {
                if let mode = CGDisplayCopyDisplayMode(displayID) {
                    refreshRate = Int(mode.refreshRate)
                    if refreshRate == 0 {
                        refreshRate = 60 // 默认值
                    }
                }
            }

            // 获取颜色空间
            var colorSpaceName = "sRGB"
            if let colorSpace = screen.colorSpace {
                colorSpaceName = colorSpace.localizedName ?? "sRGB"
            }

            // 获取显示器名称
            var displayName = "显示器 \(index + 1)"
            if let displayID = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID {
                displayName = getDisplayName(for: displayID) ?? displayName
            }

            // 获取位深度
            let bitsPerPixel = deviceDescription[NSDeviceDescriptionKey(rawValue: "NSDeviceBitsPerSample")] as? Int ?? 8
            let bitsTotal = bitsPerPixel * 4 // RGBA

            let info = DisplayInfo(
                name: displayName,
                width: Int(frame.width),
                height: Int(frame.height),
                refreshRate: refreshRate,
                scaleFactor: scaleFactor,
                colorSpace: colorSpaceName,
                isPrimary: index == 0,
                bitsPerPixel: bitsTotal
            )
            displays.append(info)
        }

        return displays
    }

    private func getDisplayName(for displayID: CGDirectDisplayID) -> String? {
        // 尝试通过 IOKit 获取显示器名称
        var iterator: io_iterator_t = 0
        let matching = IOServiceMatching("IODisplayConnect")

        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return nil
        }

        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }

            if let info = IODisplayCreateInfoDictionary(service, IOOptionBits(kIODisplayOnlyPreferredName))?.takeRetainedValue() as? [String: Any] {
                if let names = info[kDisplayProductName] as? [String: String],
                   let name = names.values.first {
                    return name
                }
            }
        }

        // 如果无法获取名称，根据是否内建显示器返回默认名称
        if CGDisplayIsBuiltin(displayID) != 0 {
            return "内建显示器"
        }
        return nil
    }
}
