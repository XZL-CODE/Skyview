//
//  CardContainerView.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct CardContainerView<Content: View>: View {
    let title: LocalizedStringKey
    let iconName: String
    let iconColor: Color
    let content: Content

    init(
        title: LocalizedStringKey,
        iconName: String,
        iconColor: Color = .blue,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.iconName = iconName
        self.iconColor = iconColor
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题栏
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()
            }

            // 内容区域
            content
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    CardContainerView(
        title: "测试卡片",
        iconName: "cpu",
        iconColor: .blue
    ) {
        VStack {
            Text("这是卡片内容")
            Text("可以放任何视图")
        }
    }
    .frame(width: 300)
    .padding()
}
