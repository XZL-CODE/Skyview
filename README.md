# Skyview

<p align="center">
  <img src="docs/images/logo.svg" alt="Skyview Logo" style="max-width: 100%; height: auto;">
</p>

<p align="center">
  <strong>macOS 系统信息监控工具</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/macOS-13.0+-brightgreen?style=flat-square" alt="macOS Version">
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square" alt="Swift">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License">
</p>

---

## 简介

Skyview 是一款轻量级的 macOS 系统监控应用，使用 SwiftUI 原生开发，帮助你实时了解 Mac 的运行状态。

<p align="center">
  <img src="docs/images/architecture.svg" alt="Architecture" style="max-width: 100%; height: auto;">
</p>

---

## 功能特性

<table>
<tr>
<td width="50%">

### 硬件监控

- **CPU** - 使用率、温度、核心信息
- **内存** - 使用量、压力、交换空间
- **GPU** - 显卡信息、显存使用
- **电池** - 电量、健康度、充电状态
- **存储** - 磁盘空间、读写速度

</td>
<td width="50%">

### 系统信息

- **网络** - 上传下载速度、IP 地址
- **进程** - 运行中的应用和进程
- **USB 设备** - 已连接的 USB 设备
- **蓝牙** - 蓝牙设备状态
- **显示器** - 分辨率、刷新率

</td>
</tr>
</table>

<p align="center">
  <img src="docs/images/features.svg" alt="Features" style="max-width: 100%; height: auto;">
</p>

---

## 系统要求

| 要求 | 最低版本 |
|------|---------|
| macOS | 13.0 (Ventura) |
| Xcode | 15.0 |
| Swift | 5.9 |

---

## 安装

### 方式一：下载安装

从 [Releases](https://github.com/XZL-CODE/Skyview/releases) 页面下载最新的 `.zip` 文件，解压后双击 `Skyview.app` 即可运行。

### 方式二：源码编译

```bash
# 克隆仓库
git clone https://github.com/yourusername/Skyview.git

# 打开项目
cd Skyview
open Skyview.xcodeproj

# 在 Xcode 中按 Cmd+R 运行
```

---

## 项目结构

```
Skyview/
├── SkyviewApp.swift          # 应用入口
├── Models/                   # 数据模型
│   ├── CPUInfo.swift
│   ├── MemoryInfo.swift
│   ├── BatteryInfo.swift
│   └── ...
├── Services/                 # 系统监控服务
│   ├── CPUMonitor.swift
│   ├── MemoryMonitor.swift
│   └── ...
├── Views/                    # 界面视图
│   ├── Dashboard/           # 仪表盘
│   ├── Cards/               # 信息卡片
│   ├── Sidebar/             # 侧边栏
│   └── Components/          # 通用组件
└── Utilities/               # 工具类
```

<p align="center">
  <img src="docs/images/structure.svg" alt="Project Structure" style="max-width: 100%; height: auto;">
</p>

---

## 技术栈

<p align="center">
  <img src="docs/images/tech-stack.svg" alt="Tech Stack" style="max-width: 100%; height: auto;">
</p>

- **SwiftUI** - 声明式 UI 框架
- **Combine** - 响应式数据流
- **IOKit** - 硬件信息读取
- **SystemConfiguration** - 网络状态监控

---

## 截图

<p align="center">
  <img src="docs/images/总览.png" alt="Skyview Logo" style="max-width: 100%; height: auto;">
</p>

---

## 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

---

## 作者

**xzl** - [GitHub](https://github.com/yourusername) · [CSDN](https://blog.csdn.net/qq_60735796)

---

<p align="center">
  <sub>使用 ❤️ 和 SwiftUI 构建</sub>
</p>
