> Template version: v0.0.1

<p align="center">
  <h1 align="center"> <code>package_info_plus</code> </h1>
</p>

This project is based on [package_info_plus](https://pub.dev/packages/package_info_plus).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  package_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/package_info_plus/package_info_plus
      ref: TAG 
...
```

Execute Command

```bash
flutter pub get
```
TAG Version Mapping

| Flutter Version | TAG | Branch |
| --- | --- | --- |
|3.7	|package_info_plus-4.2.0-ohos-1.0.0-beta.1	|master
|3.22	|package_info_plus-4.2.0-ohos.1.0.0-beta.1	|master
|3.27	|package_info_plus-9.0.0-ohos-1.0.0	|br_package_info_plus-v9.0.0_ohos
|3.35	|package_info_plus-9.0.0-ohos-1.0.0	|br_package_info_plus-v9.0.0_ohos
<!-- tabs:end -->

### 1.2 Usage

For use cases [example](example/lib/main.dart)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.27.5-ohos-0.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;
2. Flutter: 3.35.7-ohos-0.0.1; SDK: 6.0.1(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;


## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### PackageInfo API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| fromPlatform      | Retrieves and caches platform-specific package information | future | / | Future<PackageInfo> | yes |

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### PackageInfo Filters
| Name           | Description                             | Type                 | Input | Output | ohos Support |
|----------------|-----------------------------------------|----------------------|-------|--------|--------------|
| appName        | Gets application name                   | String               | /     | /      | yes          |
| packageName    | Gets package name                       | String               | /     | /      | yes          |
| version        | Gets package version                    | String               | /     | /      | yes          |
| buildNumber    | Gets build number                       | String               | /     | /      | yes          |
| buildSignature | Gets build signature                    | String               | /     | /      | yes          |
| installTime    | Gets install time                       | String               | /     | /      | yes          |
| updateTime     | Gets update time                        | String               | /     | /      | yes          |
| installerStore | Gets installer store information        | String?              | /     | /      | no           |
| data           | Gets map representation of package info | Map<String, dynamic> | /     | /      | yes          |

## 5. Known Issues

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
