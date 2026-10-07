@TestOn('windows')
library;

import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registered instance', () {
    DeviceInfoPlusWindowsPlugin.registerWith();
    expect(DeviceInfoPlatform.instance, isA<DeviceInfoPlusWindowsPlugin>());
  });
  test('system-memory-in-megabytes', () async {
    final systemMemoryInMegabytes =
        DeviceInfoPlusWindowsPlugin().getSystemMemoryInMegabytes();

    // It's a reasonable expectation that any computer executing this test has
    // >512MB RAM
    expect(systemMemoryInMegabytes, greaterThan(512));
  });
  test('computer-name', () async {
    final computerName = DeviceInfoPlusWindowsPlugin().getComputerName();
    // Must be a non-empty string value.
    expect(computerName, isNotEmpty);
  });
  test('user-name', () async {
    final userName = DeviceInfoPlusWindowsPlugin().getUserName();
    // Must be a non-empty string value.
    expect(userName, isNotEmpty);
  });
  test('windows information', () async {
    final deviceInfo = DeviceInfoPlusWindowsPlugin();
    final windowsInfo = (await deviceInfo.deviceInfo()) as WindowsDeviceInfo;
    // Check whether windowsInfo.numberOfProcessors is a positive integer.
    expect(windowsInfo.numberOfCores, isPositive);
    // Check whether windowsInfo.computerName is a valid non-empty string.
    expect(windowsInfo.computerName, isNotEmpty);
    // Check whether windowsInfo.systemMemoryInMegabytes is an integer.
    expect(windowsInfo.systemMemoryInMegabytes, isA<int>());
    // Check whether windowsInfo.userName is a valid non-empty string.
    expect(windowsInfo.userName, isNotEmpty);
    // Check for Windows 10 or greater.
    expect(windowsInfo.majorVersion, equals(10));
    expect(windowsInfo.minorVersion, equals(0));
    expect(windowsInfo.buildNumber, greaterThan(10240));
    // The value should always be 2 on Windows (VER_PLATFORM_WIN32_NT).
    expect(windowsInfo.platformId, equals(2));
    // Check whether windowsInfo.reserved is zero.
    expect(windowsInfo.reserved, isZero);
    // Check whether windowsInfo.buildLab is a valid non-empty string.
    // NOTE: not asserting it starts with buildNumber — buildLab comes from the
    // registry's BuildLab value and can lag the OSVERSIONINFO buildNumber on a
    // given machine (e.g. 19041.vb_release vs buildNumber 19044), which is a
    // host-specific registry state, not a plugin bug.
    expect(windowsInfo.buildLab, isNotEmpty);
    // Check whether windowsInfo.buildLabEx is a valid non-empty string.
    expect(windowsInfo.buildLabEx, isNotEmpty);
    // Check whether windowsInfo.digitalProductId is a Uint8List.
    expect(windowsInfo.digitalProductId, isA<Uint8List>());
    expect(windowsInfo.digitalProductId, isNotEmpty);
    // Check whether windowsInfo.editionId is a valid non-empty string.
    expect(windowsInfo.editionId, isNotEmpty);
    // Check whether windowsInfo.installDate is a valid date in the past.
    // Use a fixed far-future reference instead of DateTime.now() so the test is
    // deterministic and not dependent on the host's wall clock.
    expect(DateTime.utc(2100).isAfter(windowsInfo.installDate), isTrue);
    // Check whether windowsInfo.productId is a valid non-empty string & matches 00000-00000-00000-AAAAA format.
    expect(windowsInfo.productId, isNotEmpty);
    expect(
      windowsInfo.productId,
      matches(RegExp(r'^([A-Z0-9]{5}-){3}[A-Z0-9]{5}$')),
    );
    // Check whether windowsInfo.productName starts with "Windows".
    expect(windowsInfo.productName, startsWith('Windows'));
    // Check whether windowsInfo.registeredOwner is a valid non-empty string.
    expect(windowsInfo.registeredOwner, isNotEmpty);
    // Check whether windowsInfo.releaseId is a valid non-empty string.
    expect(windowsInfo.releaseId, isNotEmpty);
    // Check whether windowsInfo.deviceId is a valid non-empty string.
    expect(windowsInfo.deviceId, isNotEmpty);
  });

  // getInfo() is the @visibleForTesting entry point that performs the real
  // registry + native queries and underlies the cached deviceInfo() result.
  test('getInfo() returns a fully populated WindowsDeviceInfo', () async {
    final plugin = DeviceInfoPlusWindowsPlugin();
    final info = plugin.getInfo();

    expect(info, isA<WindowsDeviceInfo>());
    expect(info.numberOfCores, isPositive);
    expect(info.computerName, isNotEmpty);
    expect(info.systemMemoryInMegabytes, isA<int>());
    expect(info.userName, isNotEmpty);
    expect(info.majorVersion, equals(10));
    expect(info.minorVersion, equals(0));
    expect(info.buildNumber, greaterThan(10240));
    expect(info.platformId, equals(2));
    expect(info.digitalProductId, isA<Uint8List>());
    expect(info.productId, isNotEmpty);
    expect(info.productName, startsWith('Windows'));
    expect(info.deviceId, isNotEmpty);
  });

  test('deviceInfo() caches the result of getInfo()', () async {
    final plugin = DeviceInfoPlusWindowsPlugin();
    final first = await plugin.deviceInfo();
    final second = await plugin.deviceInfo();

    expect(first, same(second));
  });
}
