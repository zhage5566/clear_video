# clear_video — 视频清晰化一键工具

把**模糊、卡顿的短视频**，一键变成**清晰 + 丝滑**的高帧率高分辨率版本。

原理：AI 补帧（RIFE，变流畅）+ AI 超分（Real-ESRGAN，变清晰）。免安装 Python/CUDA/PyTorch，双击即用。

---

## 三种用法

| 方式 | 怎么做 | 适合 |
| --- | --- | --- |
| 🖱️ **图形界面（推荐）** | 双击 `视频清晰化工具.hta`，自选参数 | 新手 |
| 🎯 **拖拽一键** | 把视频拖到 `视频清晰化.bat` 上 | 快速 |
| ⌨️ **命令行** | 见 [`命令行使用说明.md`](./命令行使用说明.md) | 精确控制 |

---

## 第一次用：装 4 样东西（只装一次）

> 二进制与模型体积大、有各自开源许可，本仓库**不直接分发**，需自行下载。

1. **ffmpeg** —— 命令行运行 `winget install Gyan.FFmpeg`，装完重开命令行。
2. **Real-ESRGAN** —— 到 <https://github.com/xinntao/Real-ESRGAN/releases> 下载，把 `realesrgan-ncnn-vulkan.exe` 和 `models\` 放到本项目目录。
3. **rife-ncnn-vulkan** —— 到 <https://github.com/nihui/rife-ncnn-vulkan/releases> 下载，解压放到 `rife-ncnn-vulkan\` 内（路径见 `README_windows.md`）。
4. **VC++ 运行库** —— 安装 [Microsoft Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)。

---

## 输出卡顿 / 掉帧？

默认输出 H.264，在 8K@120fps 等高规格下会超出 NVIDIA 显卡硬解上限（H.264 硬解最高 4K），导致播放掉帧。

GUI 里编码器选 **HEVC**，或把 `视频清晰化.bat` 顶部 `set "USE_HEVC=0"` 改成 `1`，即改用 `hevc_nvenc` 输出 HEVC（NVIDIA 硬解支持到 8K）。

---

## 文档

| 文档 | 内容 |
| --- | --- |
| [`命令行使用说明.md`](./命令行使用说明.md) | 命令行 / 拖拽用法与参数表 |
| [`技术文档.md`](./技术文档.md) | 补帧 / 超分原理、掉帧根因、许可证（原文档保留） |
| [`README_windows.md`](./README_windows.md) | 原始详细使用说明（原文档保留） |

---

## 许可证

本仓库的 `.bat` / `.hta` / 文档以 **MIT** 许可发布（见 `LICENSE`）。

底层依赖各自独立许可：Real-ESRGAN（BSD-3-Clause）、rife-ncnn-vulkan（MIT）、ncnn（BSD-3-Clause）、ffmpeg（LGPL/GPL）。

## 致谢

- [xinntao/Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN) — Real-ESRGAN: Training Real-World Blind Super-Resolution with Pure Synthetic Data
- [nihui/rife-ncnn-vulkan](https://github.com/nihui/rife-ncnn-vulkan) — RIFE 的 ncnn/Vulkan 移植
- [Tencent/ncnn](https://github.com/Tencent/ncnn) — 高性能神经网络推理框架

## 图片超分

把图片拖到 `图片超分.bat`，或执行 `图片超分.bat "图片路径" 2 realesr-animevideov3`。需要上述 Real-ESRGAN 依赖。
