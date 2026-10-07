import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$IosDeviceInfo fromMap | toMap', () {
    late final IosDeviceInfo iosDeviceInfo;
    late final Map<String, dynamic> iosDeviceInfoMap;

    setUpAll(() {
      const iosUtsnameMap = <String, dynamic>{
        'release': 'release',
        'version': 'version',
        'machine': 'machine',
        'sysname': 'sysname',
        'nodename': 'nodename',
      };
      iosDeviceInfoMap = <String, dynamic>{
        'name': 'name',
        'model': 'model',
        'modelName': 'modelName',
        'utsname': iosUtsnameMap,
        'systemName': 'systemName',
        'isPhysicalDevice': true,
        'isiOSAppOnMac': true,
        'physicalRamSize': 8192,
        'availableRamSize': 4096,
        'systemVersion': 'systemVersion',
        'localizedModel': 'localizedModel',
        'identifierForVendor': 'identifierForVendor',
        'freeDiskSize': 4096,
        'totalDiskSize': 8192,
      };

      iosDeviceInfo = IosDeviceInfo.fromMap(iosDeviceInfoMap);
    });

    test('fromMap should return $IosDeviceInfo with correct values', () {
      expect(iosDeviceInfo.name, 'name');
      expect(iosDeviceInfo.model, 'model');
      expect(iosDeviceInfo.modelName, 'modelName');
      expect(iosDeviceInfo.isPhysicalDevice, isTrue);
      expect(iosDeviceInfo.isiOSAppOnMac, isTrue);
      expect(iosDeviceInfo.physicalRamSize, 8192);
      expect(iosDeviceInfo.availableRamSize, 4096);
      expect(iosDeviceInfo.systemName, 'systemName');
      expect(iosDeviceInfo.systemVersion, 'systemVersion');
      expect(iosDeviceInfo.localizedModel, 'localizedModel');
      expect(iosDeviceInfo.freeDiskSize, 4096);
      expect(iosDeviceInfo.totalDiskSize, 8192);
      expect(iosDeviceInfo.utsname.release, 'release');
      expect(iosDeviceInfo.utsname.version, 'version');
      expect(iosDeviceInfo.utsname.machine, 'machine');
      expect(iosDeviceInfo.utsname.sysname, 'sysname');
      expect(iosDeviceInfo.utsname.nodename, 'nodename');
    });

    test('toMap should return map with correct key and map', () {
      expect(iosDeviceInfo.data, equals(iosDeviceInfoMap));
    });
  });

  group('$IosDeviceInfo.setMockInitialValues', () {
    final utsname = IosUtsname.setMockInitialValues(
      sysname: 'Darwin',
      nodename: 'node',
      release: 'release',
      version: 'version',
      machine: 'iPhone14,3',
    );

    test('constructs an instance from explicit mock values', () {
      final info = IosDeviceInfo.setMockInitialValues(
        name: 'iPhone',
        systemName: 'iOS',
        systemVersion: '17.0',
        model: 'iPhone',
        modelName: 'iPhone 13 Pro',
        localizedModel: 'iPhone',
        freeDiskSize: 1000,
        totalDiskSize: 2000,
        isPhysicalDevice: true,
        isiOSAppOnMac: false,
        physicalRamSize: 6144,
        availableRamSize: 2048,
        utsname: utsname,
      );

      expect(info.name, 'iPhone');
      expect(info.systemVersion, '17.0');
      expect(info.isPhysicalDevice, isTrue);
      expect(info.utsname.machine, 'iPhone14,3');
      // Optional field defaults to null when omitted.
      expect(info.identifierForVendor, isNull);
      // The mock must also produce a valid backing data map.
      expect(info.data['name'], 'iPhone');
    });

    test('produces a data map that round-trips through fromMap', () {
      final info = IosDeviceInfo.setMockInitialValues(
        name: 'iPad',
        systemName: 'iOS',
        systemVersion: '16.0',
        model: 'iPad',
        modelName: 'iPad Pro',
        localizedModel: 'iPad',
        freeDiskSize: 500,
        totalDiskSize: 1000,
        identifierForVendor: 'IDFV',
        isPhysicalDevice: false,
        isiOSAppOnMac: true,
        physicalRamSize: 4096,
        availableRamSize: 1024,
        utsname: utsname,
      );

      final restored = IosDeviceInfo.fromMap(info.data);

      expect(restored.name, info.name);
      expect(restored.identifierForVendor, 'IDFV');
      expect(restored.isPhysicalDevice, info.isPhysicalDevice);
      expect(restored.isiOSAppOnMac, info.isiOSAppOnMac);
      expect(restored.utsname.machine, info.utsname.machine);
    });
  });

  group('$IosUtsname.setMockInitialValues', () {
    test('constructs a utsname with all fields set', () {
      final utsname = IosUtsname.setMockInitialValues(
        sysname: 'Darwin',
        nodename: 'node',
        release: 'release',
        version: 'version',
        machine: 'iPhone14,3',
      );

      expect(utsname.sysname, 'Darwin');
      expect(utsname.nodename, 'node');
      expect(utsname.release, 'release');
      expect(utsname.version, 'version');
      expect(utsname.machine, 'iPhone14,3');
    });
  });

  group('$IosDeviceInfo fromMap boundary scenarios', () {
    // The base map has every required field *except* identifierForVendor and
    // (for the throw cases) the utsname sub-map.
    Map<String, dynamic> baseWithoutUtsname() => <String, dynamic>{
          'name': 'iPhone',
          'systemName': 'iOS',
          'systemVersion': '17.0',
          'model': 'iPhone',
          'modelName': 'iPhone',
          'localizedModel': 'iPhone',
          'isPhysicalDevice': true,
          'isiOSAppOnMac': false,
          'freeDiskSize': 0,
          'totalDiskSize': 0,
          'physicalRamSize': 0,
          'availableRamSize': 0,
        };

    const fullUtsname = <String, dynamic>{
      'sysname': 'Darwin',
      'nodename': 'node',
      'release': 'release',
      'version': 'version',
      'machine': 'iPhone14,3',
    };

    test('throws when the utsname sub-map is empty (all fields null)', () {
      // IosUtsname fields are non-nullable String, so an empty sub-map yields
      // null values that fail the type cast — a genuine boundary behavior.
      expect(
        () => IosDeviceInfo.fromMap({
          ...baseWithoutUtsname(),
          'utsname': <String, dynamic>{},
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws when the utsname key is absent', () {
      // Absent key falls back to an empty map via `?? {}`, which then throws
      // for the same reason as above.
      expect(
        () => IosDeviceInfo.fromMap(baseWithoutUtsname()),
        throwsA(isA<TypeError>()),
      );
    });

    test('allows identifierForVendor to be absent (null) with a full utsname',
        () {
      final info = IosDeviceInfo.fromMap(<String, dynamic>{
        ...baseWithoutUtsname(),
        'utsname': fullUtsname,
      });

      expect(info.identifierForVendor, isNull);
      expect(info.utsname.machine, 'iPhone14,3');
    });
  });
}
