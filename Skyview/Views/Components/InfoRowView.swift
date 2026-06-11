//
//  InfoRowView.swift
//  Skyview
//
//  Created by xzl on 2026/1/23.
//

import SwiftUI

struct InfoRowView: View {
    let label: LocalizedStringKey
    let value: String
    let valueColor: Color

    init(label: LocalizedStringKey, value: String, valueColor: Color = .primary) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

struct InfoRowWithIconView: View {
    let iconName: String
    let iconColor: Color
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 12))
                .foregroundColor(iconColor)
                .frame(width: 16)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        InfoRowView(label: "总内存", value: "16 GB")
        InfoRowView(label: "已使用", value: "12 GB", valueColor: .orange)
        Divider()
        InfoRowWithIconView(
            iconName: "arrow.down.circle.fill",
            iconColor: .green,
            label: "下载",
            value: "125 MB/s"
        )
        InfoRowWithIconView(
            iconName: "arrow.up.circle.fill",
            iconColor: .blue,
            label: "上传",
            value: "45 MB/s"
        )
    }
    .padding()
    .frame(width: 250)
}
