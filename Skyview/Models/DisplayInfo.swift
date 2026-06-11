//
//  DisplayInfo.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import Foundation

nonisolated struct DisplayInfo: Identifiable {
    let id = UUID()
    var name: String
    var width: Int
    var height: Int
    var refreshRate: Int
    var scaleFactor: Double
    var colorSpace: String
    var isPrimary: Bool
    var bitsPerPixel: Int

    var resolution: String {
        "\(width) × \(height)"
    }

    var nativeResolution: String {
        "\(Int(Double(width) * scaleFactor)) × \(Int(Double(height) * scaleFactor))"
    }

    static var placeholder: DisplayInfo {
        DisplayInfo(
            name: "内建显示器",
            width: 1920,
            height: 1080,
            refreshRate: 60,
            scaleFactor: 2.0,
            colorSpace: "sRGB",
            isPrimary: true,
            bitsPerPixel: 32
        )
    }
}
