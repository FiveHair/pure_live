// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$MacOsDeviceInfo', () {
    group('fromMap | data', () {
      const macosDeviceInfoMap = <String, dynamic>{
        'arch': 'arch',
        'model': 'Mac16,2',
        'modelName': 'iMac (24-inch, 2024)',
        'activeCPUs': 4,
        'memorySize': 16,
        'cpuFrequency': 2,
        'hostName': 'hostName',
        'osRelease': 'osRelease',
        'majorVersion': 10,
        'minorVersion': 9,
        'patchVersion': 3,
        'computerName': 'computerName',
        'kernelVersion': 'kernelVersion',
        'systemGUID': null,
      };

      test('fromMap should return $MacOsDeviceInfo with correct values', () {
        final macosDeviceInfo = MacOsDeviceInfo.fromMap(macosDeviceInfoMap);
        expect(macosDeviceInfo.arch, 'arch');
        expect(macosDeviceInfo.model, 'Mac16,2');
        expect(macosDeviceInfo.modelName, 'iMac (24-inch, 2024)');
        expect(macosDeviceInfo.activeCPUs, 4);
        expect(macosDeviceInfo.memorySize, 16);
        expect(macosDeviceInfo.cpuFrequency, 2);
        expect(macosDeviceInfo.hostName, 'hostName');
        expect(macosDeviceInfo.osRelease, 'osRelease');
        expect(macosDeviceInfo.majorVersion, 10);
        expect(macosDeviceInfo.minorVersion, 9);
        expect(macosDeviceInfo.patchVersion, 3);
        expect(macosDeviceInfo.systemGUID, isNull);
      });

      test('toMap should return map with correct key and map', () {
        final macosDeviceInfo = MacOsDeviceInfo.fromMap(macosDeviceInfoMap);
        expect(macosDeviceInfo.data, macosDeviceInfoMap);
      });
    });

    group('setMockInitialValues', () {
      test('constructs an instance from explicit mock values', () {
        final info = MacOsDeviceInfo.setMockInitialValues(
          computerName: 'MacBook',
          hostName: 'host',
          arch: 'arm64',
          model: 'Mac14,2',
          modelName: 'MacBook Pro',
          kernelVersion: '22.0',
          osRelease: '22.0',
          majorVersion: 13,
          minorVersion: 0,
          patchVersion: 0,
          activeCPUs: 8,
          memorySize: 17179869184,
          cpuFrequency: 0,
          systemGUID: 'GUID-1234',
        );

        expect(info.computerName, 'MacBook');
        expect(info.model, 'Mac14,2');
        expect(info.majorVersion, 13);
        expect(info.activeCPUs, 8);
        expect(info.systemGUID, 'GUID-1234');
        // The mock must also produce a valid backing data map.
        expect(info.data['computerName'], 'MacBook');
        expect(info.data['systemGUID'], 'GUID-1234');
      });

      test('produces a data map that round-trips through fromMap', () {
        final info = MacOsDeviceInfo.setMockInitialValues(
          computerName: 'Mac',
          hostName: 'host',
          arch: 'x86_64',
          model: 'MacPro1,1',
          modelName: 'Mac Pro',
          kernelVersion: '20.0',
          osRelease: '20.0',
          majorVersion: 11,
          minorVersion: 6,
          patchVersion: 2,
          activeCPUs: 4,
          memorySize: 8589934592,
          cpuFrequency: 2600,
          systemGUID: 'GUID',
        );

        final restored = MacOsDeviceInfo.fromMap(info.data);

        expect(restored.computerName, info.computerName);
        expect(restored.model, info.model);
        expect(restored.majorVersion, info.majorVersion);
        expect(restored.minorVersion, info.minorVersion);
        expect(restored.activeCPUs, info.activeCPUs);
        expect(restored.systemGUID, info.systemGUID);
      });
    });

    group('fromMap boundary scenarios', () {
      test('handles a null systemGUID', () {
        final info = MacOsDeviceInfo.fromMap(const <String, dynamic>{
          'computerName': 'Mac',
          'hostName': 'host',
          'arch': 'arm64',
          'model': 'Mac14,2',
          'modelName': 'MacBook',
          'kernelVersion': '22.0',
          'osRelease': '22.0',
          'majorVersion': 13,
          'minorVersion': 0,
          'patchVersion': 0,
          'activeCPUs': 8,
          'memorySize': 0,
          'cpuFrequency': 0,
          'systemGUID': null,
        });

        expect(info.systemGUID, isNull);
      });
    });
  });
}
