@TestOn('linux')
library;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registered instance', () {
    DeviceInfoPlusLinuxPlugin.registerWith();
    expect(DeviceInfoPlatform.instance, isA<DeviceInfoPlusLinuxPlugin>());
  });

  test('deviceInfo() returns a BaseDeviceInfo and caches the result',
      () async {
    // deviceInfo() is the public @override entry point that the platform
    // interface calls; it computes the info once and caches it via `_cache ??=`.
    // Exercise it directly (linuxInfo() merely casts its result) and assert
    // both the return type and the single-computation cache.
    final fs = MemoryFileSystem.test();
    final file = fs.file('/etc/os-release')..createSync(recursive: true);
    file.writeAsStringSync('NAME="A Linux"\nID=foo\n');

    final deviceInfo = DeviceInfoPlusLinuxPlugin(fileSystem: fs);

    final first = await deviceInfo.deviceInfo();

    expect(first, isA<BaseDeviceInfo>());
    // The cached value is a LinuxDeviceInfo under the hood.
    expect(first, isA<LinuxDeviceInfo>());

    // Second call must return the identical cached instance (no re-read).
    final second = await deviceInfo.deviceInfo();
    expect(identical(second, first), isTrue);
  });
  test('os-release', () async {
    final fs = MemoryFileSystem.test();
    final file = fs.file('/etc/os-release')..createSync(recursive: true);
    file.writeAsStringSync('''
NAME="A Linux"
VERSION="1.2.3 LTS (A Linux)"
ID=foo
ID_LIKE="bar baz"
VERSION_CODENAME=lts
VERSION_ID="1.2.3-lts"
PRETTY_NAME="A Linux 1.2.3 LTS"
BUILD_ID=1
VARIANT="Community Edition"
VARIANT_ID=community
HOME_URL="https://www.fluttercommunity.dev/"
    ''');

    final deviceInfo = DeviceInfoPlusLinuxPlugin(fileSystem: fs);
    final linuxInfo = await deviceInfo.linuxInfo();
    expect(linuxInfo.name, equals('A Linux'));
    expect(linuxInfo.version, equals('1.2.3 LTS (A Linux)'));
    expect(linuxInfo.id, equals('foo'));
    expect(linuxInfo.idLike, equals(['bar', 'baz']));
    expect(linuxInfo.versionCodename, equals('lts'));
    expect(linuxInfo.versionId, equals('1.2.3-lts'));
    expect(linuxInfo.prettyName, equals('A Linux 1.2.3 LTS'));
    expect(linuxInfo.buildId, equals('1'));
    expect(linuxInfo.variant, equals('Community Edition'));
    expect(linuxInfo.variantId, equals('community'));
  });

  test('lsb-release', () async {
    final fs = MemoryFileSystem.test();
    final file = fs.file('/etc/lsb-release')..createSync(recursive: true);
    file.writeAsStringSync('''
LSB_VERSION="LSB version"
DISTRIB_ID=distrib-id
DISTRIB_RELEASE=distrib-release
DISTRIB_CODENAME=distrib-codename
DISTRIB_DESCRIPTION="Distrib Description"
    ''');

    final deviceInfo = DeviceInfoPlusLinuxPlugin(fileSystem: fs);
    final linuxInfo = await deviceInfo.linuxInfo();
    expect(linuxInfo.name, equals('Linux'));
    expect(linuxInfo.version, equals('LSB version'));
    expect(linuxInfo.id, equals('distrib-id'));
    expect(linuxInfo.idLike, isNull);
    expect(linuxInfo.versionCodename, equals('distrib-codename'));
    expect(linuxInfo.versionId, equals('distrib-release'));
    expect(linuxInfo.prettyName, 'Distrib Description');
    expect(linuxInfo.buildId, isNull);
    expect(linuxInfo.variant, isNull);
    expect(linuxInfo.variantId, isNull);
  });

  test('precedence', () async {
    final fs = MemoryFileSystem.test();
    final osFile = fs.file('/etc/os-release')..createSync(recursive: true);
    osFile.writeAsStringSync('''
VERSION="OS version"
ID=os
    ''');
    final lsbFile = fs.file('/etc/lsb-release')..createSync(recursive: true);
    lsbFile.writeAsStringSync('''
LSB_VERSION="LSB version"
DISTRIB_ID=lsb
DISTRIB_RELEASE=distrib-release
DISTRIB_CODENAME=distrib-codename
DISTRIB_DESCRIPTION="Distrib Description"
    ''');

    final deviceInfo = DeviceInfoPlusLinuxPlugin(fileSystem: fs);
    final linuxInfo = await deviceInfo.linuxInfo();
    expect(linuxInfo.name, equals('Linux'));
    expect(linuxInfo.version, equals('OS version'));
    expect(linuxInfo.id, equals('os'));
    expect(linuxInfo.idLike, isNull);
    expect(linuxInfo.versionCodename, equals('distrib-codename'));
    expect(linuxInfo.versionId, equals('distrib-release'));
    expect(linuxInfo.prettyName, 'Distrib Description');
    expect(linuxInfo.buildId, isNull);
    expect(linuxInfo.variant, isNull);
    expect(linuxInfo.variantId, isNull);
  });

  test('machine-id', () async {
    final fs = MemoryFileSystem.test();
    final file = fs.file('/etc/machine-id')..createSync(recursive: true);
    file.writeAsStringSync('machine-id');

    final deviceInfo = DeviceInfoPlusLinuxPlugin(fileSystem: fs);
    final linuxInfo = await deviceInfo.linuxInfo();
    expect(linuxInfo.machineId, equals('machine-id'));
  });

  test('missing files', () async {
    final fs = MemoryFileSystem.test();
    final deviceInfo = DeviceInfoPlusLinuxPlugin(fileSystem: fs);
    final linuxInfo = await deviceInfo.linuxInfo();
    expect(linuxInfo.name, equals('Linux'));
    expect(linuxInfo.version, isNull);
    expect(linuxInfo.id, equals('linux'));
    expect(linuxInfo.idLike, isNull);
    expect(linuxInfo.versionCodename, isNull);
    expect(linuxInfo.versionId, isNull);
    expect(linuxInfo.prettyName, 'Linux');
    expect(linuxInfo.buildId, isNull);
    expect(linuxInfo.variant, isNull);
    expect(linuxInfo.variantId, isNull);
    expect(linuxInfo.machineId, isNull);
  });
}
