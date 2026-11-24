# 视频 / 图片高清增强工具使用说明（Real-ESRGAN 便携版）

这个工具可以**用 AI 把图片或视频放大、变清晰**，尤其擅长动漫 / 二次元画面。
它是**便携版**：无需安装 Python、CUDA、PyTorch，解压即用，双击（或命令行）就能跑。

> 本目录已经内置了运行文件和模型，你什么都不用下载，直接按下面的步骤操作即可。

---

## 一、先认识一下这个文件夹

| 文件 / 文件夹 | 作用 |
| --- | --- |
| `realesrgan-ncnn-vulkan.exe` | 主程序，负责实际的高清放大 |
| `vcomp140.dll`、`vcomp140d.dll` | 运行库，主程序依赖它们，**不要删** |
| `models\` | 内置的 AI 模型文件，**不要动** |
| `input.jpg`、`input2.jpg` | 两张测试图片，可以先拿它们练手 |
| `onepiece_demo.mp4` | 一个测试视频（海贼王片段） |

---

## 二、快速开始：增强一张图片（最简单）

1. 打开这个文件夹，在地址栏输入 `cmd` 然后回车，就会在当前文件夹打开一个命令行窗口。

   > 或者：按住 `Shift` 键在文件夹空白处点右键，选「在此处打开命令窗口 / PowerShell」。

2. 在命令行里输入下面这行，然后回车：

   ```
   realesrgan-ncnn-vulkan.exe -i input.jpg -o output.png
   ```

   （PowerShell 里如果提示找不到命令，把 `realesrgan-ncnn-vulkan.exe` 前面加上 `.\`，即 `.\realesrgan-ncnn-vulkan.exe`）

3. 等它跑完，文件夹里就会多出一个 `output.png`，就是放大 4 倍后的清晰图片。

命令含义：`-i` 是输入图片，`-o` 是输出图片，用空格隔开。

---

## 三、常用命令速查

### 1. 单张图片

```
realesrgan-ncnn-vulkan.exe -i input.jpg -o output.png
```

### 2. 指定放大倍数（2 倍 / 3 倍 / 4 倍）

```
realesrgan-ncnn-vulkan.exe -i input.jpg -o output.png -s 2
```

### 3. 指定模型（见下方「模型怎么选」）

```
realesrgan-ncnn-vulkan.exe -i input.jpg -o output.png -n realesr-animevideov3
realesrgan-ncnn-vulkan.exe -i input.jpg -o output.png -n realesrgan-x4plus
realesrgan-ncnn-vulkan.exe -i input.jpg -o output.png -n realesrgan-x4plus-anime
```

### 4. 批量处理整个文件夹（一次性把文件夹里所有图片都放大）

```
realesrgan-ncnn-vulkan.exe -i 图片文件夹 -o 输出文件夹 -n realesr-animevideov3 -s 2 -f jpg
```

> 其中 `-f jpg` 表示输出格式为 jpg（也可用 `png`、`webp`）。

---

## 四、参数说明（照着填就行）

| 参数 | 含义 | 举例 |
| --- | --- | --- |
| `-i` | 输入：图片路径，或整个文件夹 | `-i input.jpg` 或 `-i 图片文件夹` |
| `-o` | 输出：图片路径，或整个文件夹 | `-o output.png` 或 `-o 输出文件夹` |
| `-s` | 放大倍数：2 / 3 / 4（默认 4） | `-s 2` |
| `-n` | 使用的模型名（默认 `realesr-animevideov3`） | `-n realesrgan-x4plus` |
| `-f` | 输出图片格式：jpg / png / webp | `-f jpg` |
| `-t` | 分块大小，默认 0 = 自动，一般不用改 | `-t 0` |
| `-g` | 使用哪个显卡，默认自动，一般不用改 | `-g 0` |
| `-x` | 开启 tta 模式（更慢但效果略好），一般不用 | `-x` |
| `-e` | 开启图片增强 | `-e` |

---

## 五、模型怎么选

| 模型名 | 适合什么 | 可选倍数 |
| --- | --- | --- |
| `realesr-animevideov3`（默认） | **动漫 / 视频**，最通用 | 2 / 3 / 4 倍 |
| `realesrgan-x4plus` | **真实照片**、真人、风景 | 4 倍 |
| `realesrgan-x4plus-anime` | **动漫图片**（单张动漫图） | 4 倍 |

> 简单记：处理**动漫视频**用默认的 `realesr-animevideov3`；处理**真人照片**用 `realesrgan-x4plus`。

---

## 六、增强整个视频（三步）

视频本身不能直接吃进主程序，需要先把视频拆成一张张图片（帧），放大后再拼回视频。这需要用到免费工具 **ffmpeg**（本工具只负责放大，ffmpeg 负责「拆帧 / 拼帧 / 保留音频」）。

> ✅ **本机已经装好 ffmpeg（v9.0.1，已加入系统 PATH），第 0 步可跳过。**
> 只需**新开一个命令行窗口**（如果之前已经开着 cmd/PowerShell，先关掉重开），输入下面命令能打印出版本号就说明可用：
> ```
> ffmpeg -version
> ```

### 第 0 步：安装 ffmpeg（本机已完成，换电脑 / 重装系统时才需要）

- **Windows 最省事的装法（一条命令，推荐）**：在命令行里运行
  ```
  winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements
  ```
  装完后**关掉命令行窗口重新开一个**，让 PATH 生效。
- 也可以手动到 https://ffmpeg.org/download.html 下载，解压后把里面 `bin\ffmpeg.exe` 所在路径加入系统环境变量 `Path`。
- 验证：`ffmpeg -version` 能打印出版本号即成功。

### 第 1 步：把视频拆成一帧帧图片

先手动新建一个空文件夹 `tmp_frames`，然后运行：

```
ffmpeg -i onepiece_demo.mp4 -qscale:v 1 -qmin 1 -qmax 1 -fps_mode passthrough tmp_frames/frame%08d.jpg
```

> 说明：`-fps_mode passthrough` 表示「每帧都输出、不丢帧不重复」。旧教程里常见的 `-vsync 0` 在新版 ffmpeg（6.0+）里已废弃、9.0 里直接报错，本命令用的是新版写法。

### 第 2 步：用主程序把这些帧高清放大

先手动新建一个空文件夹 `out_frames`，然后运行：

```
realesrgan-ncnn-vulkan.exe -i tmp_frames -o out_frames -n realesr-animevideov3 -s 2 -f jpg
```

### 第 3 步：把放大后的帧拼回视频（保留原音频）

```
ffmpeg -i out_frames/frame%08d.jpg -i onepiece_demo.mp4 -map 0:v:0 -map 1:a:0 -c:a copy -c:v libx264 -r 24000/1001 -pix_fmt yuv420p output.mp4
```

跑完后，`output.mp4` 就是增强后的成品视频。

> `-r 24000/1001` 就是 23.976 帧/秒（示例视频的原始帧率），写成这个分数是为了精确不掉帧。**如果你的视频帧率不同**，先查一下原始帧率再替换：
> ```
> ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 你的视频.mp4
> ```
> 把输出的分数（比如 `30000/1001` = 29.97fps）填到 `-r` 后面即可。

> 提示：视频帧数很多，第 2 步会比较慢，耐心等待即可；文件夹越大耗时越久。示例视频（181 帧、640×480）在 RTX 4060 上实测第 2 步约 8 秒。

---

## 七、常见问题（FAQ）

**Q1：提示找不到命令 / 无法运行？**
- 确认你是在**本文件夹**里打开的命令行；
- PowerShell 中把 `realesrgan-ncnn-vulkan.exe` 写成 `.\realesrgan-ncnn-vulkan.exe`。

**Q2：运行后一闪就退出了，没结果？**
- 大概率是命令写错了。用上面的「先 cd 到文件夹再运行」方式，别直接双击 exe（双击会因缺参数直接退出）。

**Q3：提示缺少 Vulkan / 显卡相关报错？**
- 这个程序依赖显卡的 Vulkan 驱动。请更新显卡驱动到最新版；老旧的集成显卡可能不支持。

**Q4：输出图片有拼接痕迹 / 小方块？**
- 这是正常的：程序会先把图切成小块分别放大再拼起来，边缘偶尔会有轻微痕迹。可以加 `-x` 参数稍微改善（但会更慢）。

**Q5：处理视频时提示找不到 ffmpeg？**
- 参考「第六节第 0 步」安装并配置好 ffmpeg 即可。

---

## 附：本项目出处

- GitHub：https://github.com/xinntao/Real-ESRGAN/
- 论文：https://arxiv.org/abs/2107.10833
- 底层基于 [Tencent/ncnn](https://github.com/Tencent/ncnn) 与 [nihui/realsr-ncnn-vulkan](https://github.com/nihui/realsr-ncnn-vulkan)

> 想省事的话，我还可以帮你生成一个**双击就能跑的 bat 批处理脚本**（比如「把 input.jpg 放大到 output.png」一键完成）。需要就说一声。

---

## 八、视频补帧插帧（让卡顿视频变丝滑，RIFE）

如果你的视频**帧率低、画面卡顿**（微信视频常见「假 60fps」——其实是 24fps 内容被重复帧填充成 60fps），可以用 **RIFE** 做 AI 插帧，把真实帧率补上去，让运动变流畅。

> 注意：这跟前面 Real-ESRGAN「放大清晰」是两回事——RIFE **不放大分辨率，只增加帧数**。

> ✅ 本机已装好 `rife-ncnn-vulkan`（和 realesrgan 同作者、同样便携免安装），位置在 `E:\clear_video\rife-ncnn-vulkan\`，自带 11 个模型。

### 一键脚本（推荐，双击 / 拖拽即可）

不想手动敲四条命令？直接用目录里已经写好的 **`补帧插帧.bat`**：

- **方法 A（拖拽）**：把视频文件直接拖到 `补帧插帧.bat` 图标上松开鼠标。
- **方法 B（双击）**：双击运行，弹出提示后把视频的完整路径粘贴进去回车。

脚本会自动完成「抽音频 → 去重拆帧 → RIFE 插帧 → 拼回视频」全程，成品输出到**原视频所在目录**，文件名加 `_60fps` 后缀（例如 `微信视频.mp4` → `微信视频_60fps.mp4`）。中间过程会打印进度，跑完自动清理临时文件。

> 想改目标帧率或模型：右键 `补帧插帧.bat` →「编辑」，改最上面两行即可：
> ```
> set "TARGET_FPS=60"
> set "MODEL=rife-v4.6"
> ```
> 依赖：本机 ffmpeg 已装好、rife-ncnn-vulkan 已在 `rife-ncnn-vulkan\` 目录内（都已就绪，无需再配）。

### 四步流程（以微信视频为例，输入 `input.mp4`）

1. **抽出音频**
   ```
   ffmpeg -i input.mp4 -vn -acodec copy audio.m4a
   ```

2. **去重拆帧**（去掉假 60fps 的重复帧，还原真实帧率 ~24fps）
   ```
   ffmpeg -i input.mp4 -vf "mpdecimate,setpts=N/24/TB" -r 24 frames/frame_%08d.png
   ```
   > `24` 是去重后的真实帧率（本机用 `mpdecimate` 实测得到）。如果你的视频真实帧率不是 24，请相应改掉。先手动新建 `frames` 文件夹。

3. **RIFE 插帧**（24fps → 60fps，约 2.5 倍）
   ```
   rife-ncnn-vulkan.exe -i frames -o interp -m rife-v4.6 -n 310 -u -j 2:2:2
   ```
   > - `-n 310` 是目标总帧数（5.17 秒 × 60fps ≈ 310），按「目标fps × 时长」算；
   > - `-m rife-v4.6` 效果最好；`-u` 是 UHD 模式（4K 必需）；`-j 2:2:2` 是大图线程设置；
   > - 想要 **48fps** 就去掉 `-n`（默认 2 倍）；想要 **72fps** 就 `-n 372`（3 倍）。先手动新建 `interp` 文件夹。

4. **拼回视频**（60fps + 原音频）
   ```
   ffmpeg -framerate 60 -i interp/%08d.png -i audio.m4a -map 0:v:0 -map 1:a:0 -c:a copy -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p output_60fps.mp4
   ```

### 模型怎么选

| 模型 | 说明 |
| --- | --- |
| `rife-v4.6` | 效果最好（推荐），显存占用略高 |
| `rife-v4` / `rife-v2.3` | 均衡，显存小、速度略快 |
| `rife-anime` | 动漫 / 二次元专用 |

> 本机实测：4K（3600×2160）、5.17 秒视频，去重后 124 帧插到 310 帧（60fps），RTX 4060 上 `rife-v4.6` + `-u` 约 1 分钟跑完。

### rife-ncnn-vulkan 参数速查

| 参数 | 含义 |
| --- | --- |
| `-i` / `-o` | 输入 / 输出目录 |
| `-m` | 模型名（`rife-v4.6` 等） |
| `-n` | 目标总帧数（默认 2 倍） |
| `-u` | UHD 模式（高分辨率用） |
| `-j` | 线程 `load:proc:save`（大图用 `2:2:2`） |
| `-g` | 显卡编号（默认自动） |

出处：https://github.com/nihui/rife-ncnn-vulkan （RIFE 论文 https://arxiv.org/abs/2011.06294）

---

## 九、超分 + 补帧二合一（更清晰 + 更高帧率）

如果你**既想更清晰、又想更丝滑**，用 **`超分补帧.bat`**。它把前面「六、超分」和「八、补帧」两条流程合并成一条，一键完成：

```
抽音频 → 去重拆帧 → RIFE插帧(120fps) → Real-ESRGAN超分(2x) → 拼回视频(120fps+原音频)
```

> 顺序是「**先补帧、再超分**」：RIFE 在原分辨率下补帧最准、最省显存；超分逐帧独立，最后做不会放大插帧伪影。

**用法**（和 `补帧插帧.bat` 一样）：
- 把视频**拖到** `超分补帧.bat` 图标上松开；或**双击**后粘贴路径回车。
- 成品输出到原视频旁，文件名加 `_120fps_2x` 后缀（如 `xxx.mp4` → `xxx_120fps_2x.mp4`）。

**可调参数**（右键 →「编辑」改顶部几行）：

| 变量 | 含义 | 可选值 |
| --- | --- | --- |
| `TARGET_FPS` | 目标帧率 | 120（默认）/ 90 / 60 |
| `SCALE` | 超分倍数 | 2（默认）/ 3 / 4 |
| `RIFE_MODEL` | 补帧模型 | `rife-v4.6`（默认）等 |
| `ESRGAN_MODEL` | 超分模型 | 动漫 `realesr-animevideov3`（默认）；真人 `realesrgan-x4plus` |

> ⚠️ 模型和倍数要匹配：`realesr-animevideov3` 支持 2/3/4 倍；`realesrgan-x4plus`（真人）**只支持 4 倍**，要配 `SCALE=4`。

### 两个脚本怎么选

| 脚本 | 干什么 | 适合 |
| --- | --- | --- |
| `补帧插帧.bat` | 只补帧、不超分（60fps） | 视频**已经很清晰**（如 4K），只想变丝滑 |
| `超分补帧.bat` | 补帧 + 超分（120fps + 2x） | 视频**又糊又卡**，清晰度和帧率都要提 |

> 💡 **4K 源提醒**：已经 4K 的视频再超分到 8K，代价极大（620 帧 × 每帧几秒 ≈ 半小时以上）且肉眼难分辨。4K 源建议用 `补帧插帧.bat` 只提帧率，或 `超分补帧.bat` 里把 `SCALE=2` 改成只去噪（参考第七节）。

> 实测：640×480 视频 → `超分补帧.bat` 默认参数跑出 1280×960 @ 120fps（906 帧），全程约 2 分钟（RTX 4060）。
