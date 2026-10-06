# Pure Live 鸿蒙（HarmonyOS/OHOS）移植说明

本仓库将 [pure_live](https://github.com/liuchuancong/pure_live) 移植到鸿蒙平台：

- **手机 / 平板**：交互对齐 Android 端
- **PC（2in1 形态设备）**：自动识别（原生 `deviceType == "2in1"`），交互对齐桌面端
- 当前目标：**直播观看 + 弹幕**核心功能可用；录制、扫码、Firebase 同步等依赖
  专有二进制的功能暂缺（见文末"待适配"）

## 一、环境要求

| 组件 | 版本 | 说明 |
| ---- | ---- | ---- |
| Flutter (ohos) | `oh-3.47.4-dev` 分支（3.47.4-ohos-1.0.4 基线） | https://atomgit.com/oh-flutter/flutter_flutter，需含 PR#1（Windows 宿主 dart-sdk 修复） |
| HarmonyOS SDK | API 26（DevEco Studio 26 或 command-line tools） | 含 ohpm / hvigor / node |
| 环境变量 | `TOOL_HOME` | DevEco 安装目录（其下有 `tools/hvigor`）或 CLI tools 目录（其下有 `tools/hvigor`） |
| 环境变量 | `DEVECO_SDK_HOME` | HarmonyOS SDK 目录 |
| 环境变量 | `PUB_HOSTED_URL=https://pub.flutter-io.cn`、`FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn` | 国内镜像 |
| git 配置 | `git config --global url."https://atomgit.com/".insteadOf "git@atomgit.com:"` | flutter_tools 的 pub 依赖用 SSH 形式引用 atomgit 仓库 |
| 环境变量 | `GIT_LFS_SKIP_SMUDGE=1`（pub get 时） | 部分仓库 LFS 对象服务端缺失 |

注意：oh-flutter 官方仅提供 **Windows / macOS 宿主**的定制 dart-sdk（含
`Abi.ohosArm` 等 dart:ffi 扩展，编译 flutter_tools 必需），**Linux 宿主无法引导
此 SDK**——CI 因此跑在 windows-latest 上。

## 二、伴生仓库（本地路径依赖）

上游 pubspec 用作者机器的绝对路径（`F:/media_core`、`E:/software/flame_barrage`）
引用两个私有仓库，两者在 GitHub 均有公开镜像，克隆到本地后按
`pubspec.yaml` 中 `dependency_overrides` 的 `D:/DEV/...` 路径放置（或自行改路径）：

```bash
git clone https://github.com/liuchuancong/media_core.git   D:/DEV/media_core
git clone https://github.com/liuchuancong/flame_barrage.git D:/DEV/flame_barrage
# media-kit 本地副本（ohos 编译补丁，锁定上游 commit）
git clone https://github.com/Predidit/media-kit.git D:/DEV/media-kit-predidit
cd D:/DEV/media-kit-predidit && git checkout 803c4a27
```

## 三、构建

```bash
flutter pub get          # GIT_LFS_SKIP_SMUDGE=1
flutter build hap --debug
# 产物: ohos/entry/build/default/outputs/default/entry-default-unsigned.hap
```

安装到真机需签名（DevEco Studio → File → Project Structure → Signing Configs）。

## 四、SDK 补丁（每次克隆/切分支后重放）

`tool/patch_ohflutter_tools.py <sdk路径>` 修补两处（幂等，自动清 flutter_tools 快照）：

1. `flutter_tools/hvigor/src/plugin/flutter-hvigor-plugin.ts`：native assets
   复制到 entry/libs 时 `endsWith('.so')` 会漏掉 `libmpv.so.2` 这类带版本号
   的库（**libmpv 缺失 = 运行必然白屏**），改为 `.so`/`.so.N` 正则
2. `flutter_tools/lib/src/ohos/ohos_builder.dart`：同步放宽（防御性）

ohos/hvigorw.bat 与 ohos/tool-shims/ohpm.bat 为 Windows 构建垫片：
DevEco 的 ohpm.bat 有无限批处理递归 bug，垫片直接以 node 运行 pm-cli.js 绕开。

## 五、移植内容

### 平台判定（lib/core/platform/platform_utils.dart）

- `PlatformUtils.isOhos`（`Platform.isOhos`，定制 SDK 提供）
- 启动时经原生通道 `com.mystyle.purelive/intent` 的 `checkOhosIsDesktop`
  识别设备形态：`deviceType == "2in1"` → `isOhosPC = true`
- `isDesktop` / `isMobile` / `select()` 均包含 ohos 分支，全应用自动适配

### ohos 工程（ohos/）

- 原生插件 `MethodCall.ets`：原生全屏（隐藏状态栏/导航小白条、横屏自动旋转、
  智慧多窗）、设备形态判定、文件保存对话框、AVSession 播控中心
- module.json5：phone/tablet/2in1 三形态、avoid_cutout、后台音频播放、
  自由旋转 + 横屏多窗
- Dart 侧入口：`PlatformUtils` / 播放域内核（Predidit media-kit 自带 ohos
  视频 controller 与 ArkTS 纹理实现）

### 依赖适配（pubspec.yaml dependency_overrides）

| 依赖 | 处理 |
| ---- | ---- |
| media_kit / media_kit_video | 本地 D:/DEV/media-kit-predidit（官方即含 ohos 实现；hook 增加 OHOS clang `--target/--sysroot` 补丁） |
| flame_barrage | 本地 D:/DEV/flame_barrage（pub 0.0.8 缺宿主撤回接口） |
| path_provider(+ohos) | CPF-Flutter/flutter_packages br_path_provider-v2.1.5_ohos |
| material_ui / cupertino_ui / syncfusion_flutter_sliders / flex_color_picker | vendor 到 third_party/，修复 `TargetPlatform.ohos` 穷举 switch（oh-flutter 给 TargetPlatform 枚举新增了 ohos 值） |
| ffmpeg_kit_extended_flutter | vendor 空 hook（ohos 无官方产物，**录制功能暂缺**） |
| wakelock_plus | pub 官方已含 ohos 实现（wakelock_plus_ohos） |
| firebase 全家 | 无 ohos 实现，`FirebaseManager` 在 ohos 上直接抛 UnsupportedError（初始化入口已接 PlatformUtils 守卫） |

### 已知问题与待适配

- [ ] 录制（ffmpeg_kit 无 ohos 产物；需 ohos ffmpeg 或系统能力替代）
- [ ] 扫码（mobile_scanner 为本地 Kotlin 插件）
- [ ] Web 登录（flutter_inappwebview 无 ohos 实现，CPF 有 6.1.5 适配版可后续接入）
- [ ] 系统托盘 / 亚克力 / windows_single_instance 等桌面专属能力（ohos PC 暂无对应）
- [ ] 视频为 CPU 软解 + GPU 渲染（libmpv 交叉编译产物未启用鸿蒙硬解码；
      硬解需接系统 AVPlayer / video_player_ohos 后端，上游 media_core 无此后端）
- [ ] oh-flutter 3.47.5-ohos-1.0.0 的 flutter test 工件与分支 Dart 内核不配套
      （用 3.47.4 基线不受影响）

## 六、CI

`.github/workflows/build_ohos.yml`（windows-latest）：鸿蒙工具链 + flutter-ohos
+ SDK 补丁重放 + 伴生仓库克隆 + 路径重写 + HAP 构建 + so 完整性校验。
推送到 `ohos-support` 自动触发。

## 致谢

- [liuchuancong/pure_live](https://github.com/liuchuancong/pure_live) `原项目`
- [oh-flutter](https://atomgit.com/oh-flutter) `Flutter OH SDK 与 Windows 宿主修复（PR#1）`
- [CPF-Flutter](https://gitcode.com/CPF-Flutter) `鸿蒙插件适配生态`
- [Predidit/media-kit](https://github.com/Predidit/media-kit) `ohos 视频管线`
- [ErBWs/setup-ohos](https://github.com/ErBWs/setup-ohos) `CI 鸿蒙工具链`
- [ErBWs/Kazumi](https://github.com/ErBWs/Kazumi) `鸿蒙适配参考`
