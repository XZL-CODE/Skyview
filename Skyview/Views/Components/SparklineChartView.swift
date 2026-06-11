//
//  SparklineChartView.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct SparklineChartView: View {
    let data: [Double]
    let lineColor: Color
    let fillGradient: [Color]
    let height: CGFloat

    init(
        data: [Double],
        lineColor: Color = .blue,
        fillGradient: [Color]? = nil,
        height: CGFloat = 40
    ) {
        self.data = data
        self.lineColor = lineColor
        self.fillGradient = fillGradient ?? [lineColor.opacity(0.3), lineColor.opacity(0.0)]
        self.height = height
    }

    var body: some View {
        GeometryReader { geometry in
            if data.count >= 2 {
                let maxValue = max(data.max() ?? 1, 1)
                let minValue = data.min() ?? 0
                let range = max(maxValue - minValue, 1)

                ZStack {
                    // 填充区域
                    Path { path in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)

                        path.move(to: CGPoint(x: 0, y: geometry.size.height))

                        for (index, value) in data.enumerated() {
                            let normalizedValue = (value - minValue) / range
                            let x = CGFloat(index) * stepX
                            let y = geometry.size.height * (1 - CGFloat(normalizedValue))
                            path.addLine(to: CGPoint(x: x, y: y))
                        }

                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: fillGradient),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    // 线条
                    Path { path in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)

                        for (index, value) in data.enumerated() {
                            let normalizedValue = (value - minValue) / range
                            let x = CGFloat(index) * stepX
                            let y = geometry.size.height * (1 - CGFloat(normalizedValue))

                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                .animation(.easeInOut(duration: 0.3), value: data)
            } else {
                // 无数据时显示占位线
                Path { path in
                    let y = geometry.size.height / 2
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        SparklineChartView(
            data: [20, 35, 25, 40, 55, 45, 60, 50, 70, 65],
            lineColor: .cpuGradientStart
        )

        SparklineChartView(
            data: [50, 55, 60, 58, 62, 70, 75, 72, 78, 80],
            lineColor: .memoryGradientStart
        )

        SparklineChartView(
            data: [],
            lineColor: .gray
        )
    }
    .padding()
    .frame(width: 200)
}
