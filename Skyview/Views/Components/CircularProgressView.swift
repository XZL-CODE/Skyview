//
//  CircularProgressView.swift
//  XZL-TEST
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradientColors: [Color]
    let showPercentage: Bool
    let size: CGFloat

    init(
        progress: Double,
        lineWidth: CGFloat = 12,
        gradientColors: [Color] = [.blue, .purple],
        showPercentage: Bool = true,
        size: CGFloat = 100
    ) {
        self.progress = min(max(progress, 0), 100)
        self.lineWidth = lineWidth
        self.gradientColors = gradientColors
        self.showPercentage = showPercentage
        self.size = size
    }

    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // 进度圆环
            Circle()
                .trim(from: 0, to: progress / 100)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // 百分比文字
            if showPercentage {
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", progress))
                        .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("%")
                        .font(.system(size: size * 0.12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 20) {
        CircularProgressView(
            progress: 75,
            gradientColors: [.cpuGradientStart, .cpuGradientEnd]
        )

        CircularProgressView(
            progress: 45,
            gradientColors: [.memoryGradientStart, .memoryGradientEnd]
        )

        CircularProgressView(
            progress: 23,
            lineWidth: 8,
            gradientColors: [.storageGradientStart, .storageGradientEnd],
            size: 80
        )
    }
    .padding()
}
