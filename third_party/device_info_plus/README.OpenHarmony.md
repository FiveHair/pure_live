<p align="center">
  <h1 align="center"> <code>device_info_plus</code> </h1>
</p>

This project is based on [device_info_plus](https://pub.dev/packages/device_info_plus).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  device_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/device_info_plus/device_info_plus
      # ref: Select the TAG version that matches your Flutter framework version from the table below
      ref: device_info_plus-12.3.0-ohos-1.0.0
...
```

Execute Command

```bash
flutter pub get
```

> TAG naming rule: `original-library-version-ohos-version-betax`. For changes between TAGs, see CHANGELOG.OpenHarmony.md.

| Flutter Framework Version | TAG Name | Branch |
|---|---|---|
| 3.35 | device_info_plus-12.3.0-ohos-1.0.0 | br_device_info_plus-v12.3.0_ohos |

<!-- tabs:end -->

### 1.2 Usage

A complete runnable example lives in [example](example/lib/main.dart). The
minimal inline flow — from import to retrieval — is shown below.

```dart
import 'package:device_info_plus/device_info_plus.dart';

// 1. Create a plugin instance. It is safe to reuse / cache it across the app.
final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

// 2. Get OHOS device info — no permission required.
//    NOTE: `OhosDeviceInfo` is not part of the public export surface, so access
//    it through type inference (`final`) rather than naming the type explicitly.
final ohosInfo = await deviceInfoPlugin.ohosDeviceInfo;

print('brand           : ${ohosInfo.brand}');
print('productModel    : ${ohosInfo.productModel}');
print('osFullName      : ${ohosInfo.osFullName}');
print('sdkApiVersion   : ${ohosInfo.sdkApiVersion}');
print('isPhysicalDevice: ${ohosInfo.isPhysicalDevice}');

// OHOS-specific: ODID is carried inside the raw data map (there is no typed
// `odID` field) and only holds a valid value after the user grants the
// `ohos.permission.APP_TRACKING_CONSENT` permission.
print('ODID            : ${ohosInfo.data['ODID']}');

// 3. Get the device serial number & UDID.
//    This requires the SYSTEM-level permission `ohos.permission.sec.ACCESS_UDID`,
//    which is open only to system apps. It throws when the permission is missing,
//    so always wrap the call in try/catch.
try {
  final udidInfo = await deviceInfoPlugin.ohosAccessUDIDInfo;
  print('serial: ${udidInfo.serial}');
  print('udid  : ${udidInfo.udid}');
} catch (e) {
  print('Failed to get UDID info: $e');
}
```

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.35.7-ohos-0.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### DeviceInfoPlugin API
| Name                | Description                                                                 | Type     | Input | Output                          | ohos Support |
|---------------------|-----------------------------------------------------------------------------|----------|-------|---------------------------------|--------------|
| ohosDeviceInfo      | Retrieves device information from `@ohos.deviceInfo` | function | /     | Future<OhosDeviceInfo>          | yes          |
| ohosAccessUDIDInfo  | Retrieves device serial & UDID. **Requires the system-level permission `ohos.permission.sec.ACCESS_UDID` (system apps only); throws when the permission is missing** | function | /     | Future<OhosAccessUDIDInfo>      | yes          |
| androidInfo         | Retrieves Android device information from `android.os.Build`                    | function | /     | Future<AndroidDeviceInfo>         | no          |
| iosInfo             | Retrieves iOS device information from `UIDevice`                              | function | /     | Future<IosDeviceInfo>             | no          |
| linuxInfo           | Retrieves Linux device information from `/etc/os-release`                     | function | /     | Future<LinuxDeviceInfo>           | no          |
| webBrowserInfo      | Retrieves web browser information from `Navigator`                             | function | /     | Future<WebBrowserInfo>            | no          |
| macOsInfo           | Retrieves macOS device information from Sysctl                                | function | /     | Future<MacOsDeviceInfo>           | no          |
| windowsInfo         | Retrieves Windows device information                                        | function | /     | Future<WindowsDeviceInfo>         | no          |
| deviceInfo          | Retrieves platform-agnostic device information (auto-adapts for OHOS/Android/iOS/etc) | function | /     | Future<BaseDeviceInfo>            | yes          |

---

### BaseDeviceInfo API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| toMap             | Returns the raw device information data map (deprecated) | function | / | Map<String, dynamic> | yes |
| toString          | Returns string representation of the device info | function | / | String | yes |

---

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### OhosDeviceInfo Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| deviceType          | Gets the device type (e.g. phone/tablet/wearable) | String   | /     | /       | yes          |
| manufacture         | Gets the manufacturer name          | String   | /     | /       | yes          |
| brand               | Gets the brand name                 | String   | /     | /       | yes          |
| marketName          | Gets the marketing name             | String   | /     | /       | yes          |
| productSeries       | Gets the product series             | String   | /     | /       | yes          |
| productModel        | Gets the product model              | String   | /     | /       | yes          |
| softwareModel       | Gets the software model             | String   | /     | /       | yes          |
| hardwareModel       | Gets the hardware model             | String   | /     | /       | yes          |
| bootloaderVersion   | Gets the bootloader version         | String   | /     | /       | yes          |
| abiList             | Gets supported ABI list             | String   | /     | /       | yes          |
| securityPatchTag    | Gets security patch version         | String   | /     | /       | yes          |
| displayVersion      | Gets user-visible version string    | String   | /     | /       | yes          |
| incrementalVersion  | Gets incremental version number     | String   | /     | /       | yes          |
| osReleaseType       | Gets OS release type (e.g. "Beta")  | String   | /     | /       | yes          |
| osFullName          | Gets full OS version name           | String   | /     | /       | yes          |
| majorVersion        | Gets OS major version number        | int      | /     | /       | yes          |
| seniorVersion       | Gets OS senior version number       | int      | /     | /       | yes          |
| featureVersion      | Gets OS feature version number      | int      | /     | /       | yes          |
| buildVersion        | Gets OS build version number        | int      | /     | /       | yes          |
| sdkApiVersion       | Gets SDK API version                | int      | /     | /       | yes          |
| firstApiVersion     | Gets earliest supported API version | int      | /     | /       | yes          |
| versionId           | Gets the version ID                 | String   | /     | /       | yes          |
| buildType           | Gets build type (e.g. "user/debug") | String   | /     | /       | yes          |
| buildUser           | Gets the build user                 | String   | /     | /       | yes          |
| buildHost           | Gets the build host                 | String   | /     | /       | yes          |
| buildTime           | Gets build timestamp string         | String   | /     | /       | yes          |
| buildRootHash       | Gets the build version hash         | String   | /     | /       | yes          |
| ODID                | Gets ODID (OpenHarmony Device ID)   | String   | /     | /       | yes          |
| distributionOSName           | Gets the distribution OS name           | String   | /     | /       | yes          |
| distributionOSVersion        | Gets the distribution OS version        | String   | /     | /       | yes          |
| distributionOSApiVersion     | Gets the distribution OS API version    | int      | /     | /       | yes          |
| distributionOSReleaseType    | Gets the distribution OS release type   | String   | /     | /       | yes          |
| isPhysicalDevice    | `false` on an emulator, `true` otherwise | bool     | /     | /       | yes          |

> [!NOTE] `hardwareProfile` and `serial`/`udid` were removed from `OhosDeviceInfo`'s public fields: they are commented out in the source and no longer exposed on this model. To obtain the serial/UDID use [`ohosAccessUDIDInfo`](#ohosaccessudidinfo-filters). ODID is not a typed field — read it from `ohosInfo.data['ODID']` (valid only after `ohos.permission.APP_TRACKING_CONSENT` is granted).

---

### OhosAccessUDIDInfo Filters

> [!NOTE] Both fields require the system-level permission `ohos.permission.sec.ACCESS_UDID`, which is open only to system apps. On devices without the permission, `ohosAccessUDIDInfo` throws — always call it inside a `try/catch`.

| Name                | Description                                       | Type     | Input | Output  | ohos Support |
|---------------------|---------------------------------------------------|----------|-------|---------|--------------|
| serial              | Gets the device serial number                     | String   | /     | /       | yes          |
| udid                | Gets the device UDID                              | String   | /     | /       | yes          |

---

### BaseDeviceInfo Filters
| Name                | Description                         | Type               | Input | Output  | ohos Support |
|---------------------|-------------------------------------|--------------------|-------|---------|--------------|
| data                | Gets the raw device information data map | Map<String, dynamic> | /     | /       | yes          |

---

## 5. Known Issues

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
