<p align="center">
  <h1 align="center"> <code>device_info_plus</code> </h1>
</p>

本项目基于 [device_info_plus](https://pub.dev/packages/device_info_plus) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  device_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/device_info_plus/device_info_plus
      # ref: 根据下方表格选择不同框架适配的TAG版本
      ref: device_info_plus-12.3.0-ohos-1.0.0
...
```

执行命令

```bash
flutter pub get
```

> TAG 命名规则：`原库版本-ohos-版本号-betax`，不同 TAG 之间的变更详见 CHANGELOG.OpenHarmony.md。

| Flutter 框架版本 | TAG 名称 | 分支名 |
|---|---|---|
| 3.35 | device_info_plus-12.3.0-ohos-1.0.0 | br_device_info_plus-v12.3.0_ohos |

<!-- tabs:end -->

### 1.2 使用案例

完整可运行的示例详见 [example](example/lib/main.dart)。从导入到获取数据的最小内联流程如下：

```dart
import 'package:device_info_plus/device_info_plus.dart';

// 1. 创建插件实例。可在整个应用中安全复用 / 缓存。
final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

// 2. 获取 OHOS 设备信息 —— 无需任何权限。
//    注意：`OhosDeviceInfo` 不在公开导出范围内，请通过类型推断（`final`）访问，
//    不要显式写出类型名。
final ohosInfo = await deviceInfoPlugin.ohosDeviceInfo;

print('brand           : ${ohosInfo.brand}');
print('productModel    : ${ohosInfo.productModel}');
print('osFullName      : ${ohosInfo.osFullName}');
print('sdkApiVersion   : ${ohosInfo.sdkApiVersion}');
print('isPhysicalDevice: ${ohosInfo.isPhysicalDevice}');

// 鸿蒙特性：ODID 仅存在于原始数据字典中（没有对应的类型化字段），
// 且只有在用户授予 `ohos.permission.APP_TRACKING_CONSENT` 权限后才为有效值。
print('ODID            : ${ohosInfo.data['ODID']}');

// 3. 获取设备序列号与 UDID。
//    该接口需要系统级权限 `ohos.permission.sec.ACCESS_UDID`，仅对系统应用开放；
//    缺少权限时会抛出异常，因此务必使用 try/catch 包裹。
try {
  final udidInfo = await deviceInfoPlugin.ohosAccessUDIDInfo;
  print('serial: ${udidInfo.serial}');
  print('udid  : ${udidInfo.udid}');
} catch (e) {
  print('获取 UDID 信息失败: $e');
}
```

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.35.7-ohos-0.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### DeviceInfoPlugin API
| Name                | Description                                                                 | Type     | Input | Output                          | ohos Support |
|---------------------|-----------------------------------------------------------------------------|----------|-------|---------------------------------|--------------|
| ohosDeviceInfo      | 从 `@ohos.deviceInfo` 获取设备信息 | function | /     | Future<OhosDeviceInfo>          | yes          |
| ohosAccessUDIDInfo  | 获取设备序列号与 UDID。**需要系统级权限 `ohos.permission.sec.ACCESS_UDID`（仅系统应用可用）；权限缺失时会抛出异常** | function | /     | Future<OhosAccessUDIDInfo>      | yes          |
| androidInfo         | 从 `android.os.Build` 获取 Android 设备信息 | function | /     | Future<AndroidDeviceInfo>         | no          |
| iosInfo             | 从 `UIDevice` 获取 iOS 设备信息 | function | /     | Future<IosDeviceInfo>             | no          |
| linuxInfo           | 从 `/etc/os-release` 获取 Linux 设备信息 | function | /     | Future<LinuxDeviceInfo>           | no          |
| webBrowserInfo      | 从 `Navigator` 获取浏览器信息 | function | /     | Future<WebBrowserInfo>            | no          |
| macOsInfo           | 从 Sysctl 获取 macOS 设备信息 | function | /     | Future<MacOsDeviceInfo>           | no          |
| windowsInfo         | 获取 Windows 设备信息 | function | /     | Future<WindowsDeviceInfo>         | no          |
| deviceInfo          | 获取跨平台设备信息（自动适配 OHOS/Android/iOS 等） | function | /     | Future<BaseDeviceInfo>            | yes          |

---

### BaseDeviceInfo API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| toMap             | Returns the raw device information data map (deprecated) | function | / | Map<String, dynamic> | yes |
| toString          | Returns string representation of the device info | function | / | String | yes |

---

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### OhosDeviceInfo Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| deviceType          | 获取设备类型（如手机/平板/穿戴设备） | String   | /     | /       | yes          |
| manufacture         | 获取厂商名称 | String   | /     | /       | yes          |
| brand               | 获取品牌名称 | String   | /     | /       | yes          |
| marketName          | 获取产品市场名称 | String   | /     | /       | yes          |
| productSeries       | 获取产品系列 | String   | /     | /       | yes          |
| productModel        | 获取产品型号 | String   | /     | /       | yes          |
| softwareModel       | 获取软件模型 | String   | /     | /       | yes          |
| hardwareModel       | 获取硬件型号 | String   | /     | /       | yes          |
| bootloaderVersion   | 获取引导程序版本 | String   | /     | /       | yes          |
| abiList             | 获取支持的 ABI 列表 | String   | /     | /       | yes          |
| securityPatchTag    | 获取安全补丁标签 | String   | /     | /       | yes          |
| displayVersion      | 获取用户可见版本字符串 | String   | /     | /       | yes          |
| incrementalVersion  | 获取增量版本号 | String   | /     | /       | yes          |
| osReleaseType       | 获取操作系统发布类型（如 "Beta"） | String   | /     | /       | yes          |
| osFullName          | 获取完整操作系统版本名称 | String   | /     | /       | yes          |
| majorVersion        | 获取操作系统主版本号 | int      | /     | /       | yes          |
| seniorVersion       | 获取操作系统次版本号 | int      | /     | /       | yes          |
| featureVersion      | 获取功能版本号 | int      | /     | /       | yes          |
| buildVersion        | 获取构建版本号 | int      | /     | /       | yes          |
| sdkApiVersion       | 获取 SDK API 版本 | int      | /     | /       | yes          |
| firstApiVersion     | 获取最早支持的 API 版本 | int      | /     | /       | yes          |
| versionId           | 获取版本 ID | String   | /     | /       | yes          |
| buildType           | 获取构建类型（如 "user/debug"） | String   | /     | /       | yes          |
| buildUser           | 获取构建用户 | String   | /     | /       | yes          |
| buildHost           | 获取构建主机 | String   | /     | /       | yes          |
| buildTime           | 获取构建时间戳字符串 | String   | /     | /       | yes          |
| buildRootHash       | 获取构建版本 Hash | String   | /     | /       | yes          |
| ODID                | 获取 ODID（OpenHarmony 设备 ID） | String   | /     | /       | yes          |
| distributionOSName           | 获取发行版系统名称     | String   | /     | /       | yes          |
| distributionOSVersion        | 获取发行版系统版本号   | String   | /     | /       | yes          |
| distributionOSApiVersion     | 获取发行版系统 API 版本号 | int      | /     | /       | yes          |
| distributionOSReleaseType    | 获取发行版系统类型     | String   | /     | /       | yes          |
| isPhysicalDevice    | 是否物理设备（模拟器为 false） | bool     | /     | /       | yes          |

> [!NOTE] `hardwareProfile` 与 `serial`/`udid` 已从 `OhosDeviceInfo` 的公开字段中移除：源码中已注释掉，本模型不再暴露。如需获取序列号/UDID，请使用 [`ohosAccessUDIDInfo`](#ohosaccessudidinfo-filters)。ODID 不是类型化字段，请通过 `ohosInfo.data['ODID']` 读取（仅在授予 `ohos.permission.APP_TRACKING_CONSENT` 后为有效值）。

---

### OhosAccessUDIDInfo Filters

> [!NOTE] 以下两个字段均需要系统级权限 `ohos.permission.sec.ACCESS_UDID`，仅对系统应用开放。缺少权限时 `ohosAccessUDIDInfo` 会抛出异常，请务必在 `try/catch` 中调用。

| Name                | Description                                       | Type     | Input | Output  | ohos Support |
|---------------------|---------------------------------------------------|----------|-------|---------|--------------|
| serial              | 获取设备序列号                     | String   | /     | /       | yes          |
| udid                | 获取设备 UDID                              | String   | /     | /       | yes          |

---

### BaseDeviceInfo Filters
| Name                | Description                         | Type               | Input | Output  | ohos Support |
|---------------------|-------------------------------------|--------------------|-------|---------|--------------|
| data                | 获取原始设备信息数据字典 | Map<String, dynamic> | /     | /       | yes          |

---

## 5. 遗留问题

## 6. 其他

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](LICENSE) ，请自由地享受和参与开源。
