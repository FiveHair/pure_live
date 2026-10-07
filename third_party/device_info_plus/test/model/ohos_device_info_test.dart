// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/src/model/ohos_device_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// Full-coverage sample map for [OhosDeviceInfo.fromMap]. Every key has a
/// non-default value so the test can assert that [fromMap] preserves it.
const Map<String, dynamic> _sampleOhosInfo = <String, dynamic>{
  'deviceType': 'phone',
  'manufacture': 'mfg',
  'brand': 'DEMO-brand',
  'marketName': 'market',
  'productSeries': 'series',
  'productModel': 'model',
  'softwareModel': 'sw',
  'hardwareModel': 'hw',
  'bootloaderVersion': 'boot',
  'abiList': 'arm64-v8a',
  'securityPatchTag': 'patch',
  'displayVersion': 'display',
  'incrementalVersion': 'incr',
  'osReleaseType': 'Release',
  'osFullName': 'DEMO-osFullName',
  'majorVersion': 5,
  'seniorVersion': 0,
  'featureVersion': 1,
  'buildVersion': 99,
  'sdkApiVersion': 12,
  'firstApiVersion': 9,
  'versionId': 'vid',
  'buildType': 'release',
  'buildUser': 'user',
  'buildHost': 'host',
  'buildTime': 'time',
  'buildRootHash': 'hash',
  'distributionOSName': 'name',
  'distributionOSVersion': '1.0',
  'distributionOSApiVersion': 12,
  'distributionOSReleaseType': 'Release',
  'isPhysicalDevice': true,
};

void main() {
  // OhosDeviceInfo / OhosAccessUDIDInfo are pure value objects: no channel,
  // no platform, no I/O, so there is no shared state to reset between cases.
  // The lifecycle hooks are kept per testing convention to draw a clean
  // boundary between tests and give any future stateful additions an obvious
  // place to hook in.
  setUp(() {});
  tearDown(() {});

  group('$OhosDeviceInfo', () {
    group('fromMap', () {
      final info = OhosDeviceInfo.fromMap(_sampleOhosInfo);

      test('parses every string field', () {
        expect(info.deviceType, 'phone');
        expect(info.manufacture, 'mfg');
        expect(info.brand, 'DEMO-brand');
        expect(info.marketName, 'market');
        expect(info.productSeries, 'series');
        expect(info.productModel, 'model');
        expect(info.softwareModel, 'sw');
        expect(info.hardwareModel, 'hw');
        expect(info.bootloaderVersion, 'boot');
        expect(info.abiList, 'arm64-v8a');
        expect(info.securityPatchTag, 'patch');
        expect(info.displayVersion, 'display');
        expect(info.incrementalVersion, 'incr');
        expect(info.osReleaseType, 'Release');
        expect(info.osFullName, 'DEMO-osFullName');
        expect(info.versionId, 'vid');
        expect(info.buildType, 'release');
        expect(info.buildUser, 'user');
        expect(info.buildHost, 'host');
        expect(info.buildTime, 'time');
        expect(info.buildRootHash, 'hash');
        expect(info.distributionOSName, 'name');
        expect(info.distributionOSVersion, '1.0');
        expect(info.distributionOSReleaseType, 'Release');
      });

      test('parses every int field and keeps the int runtime type', () {
        expect(info.majorVersion, 5);
        expect(info.seniorVersion, 0);
        expect(info.featureVersion, 1);
        expect(info.buildVersion, 99);
        expect(info.sdkApiVersion, 12);
        expect(info.firstApiVersion, 9);
        expect(info.distributionOSApiVersion, 12);

        expect(info.majorVersion, isA<int>());
        expect(info.buildVersion, isA<int>());
      });

      test('parses the bool field and keeps the bool runtime type', () {
        expect(info.isPhysicalDevice, isTrue);
        expect(info.isPhysicalDevice, isA<bool>());
      });

      test('falls back to defaults when fields are missing', () {
        final info = OhosDeviceInfo.fromMap(<String, dynamic>{});

        expect(info.deviceType, isEmpty);
        expect(info.brand, isEmpty);
        expect(info.osFullName, isEmpty);
        expect(info.majorVersion, 0);
        expect(info.buildVersion, 0);
        expect(info.distributionOSApiVersion, 0);
        expect(info.isPhysicalDevice, isFalse);
      });

      test('falls back to defaults when fields are explicitly null', () {
        final info = OhosDeviceInfo.fromMap(<String, dynamic>{
          'brand': null,
          'osFullName': null,
          'majorVersion': null,
          'isPhysicalDevice': null,
        });

        expect(info.brand, isEmpty);
        expect(info.osFullName, isEmpty);
        expect(info.majorVersion, 0);
        expect(info.isPhysicalDevice, isFalse);
      });

      test('treats isPhysicalDevice strictly (only literal true is true)', () {
        // `isPhysicalDevice == true` — a truthy non-bool must NOT read as true.
        final info = OhosDeviceInfo.fromMap(<String, dynamic>{
          'isPhysicalDevice': 'yes',
        });
        expect(info.isPhysicalDevice, isFalse);
      });
    });

    group('toJson', () {
      test('contains all 32 active fields', () {
        // 27 String + 6 int + 1 bool = 32. The deprecated hardwareProfile /
        // serial / udid fields are deliberately omitted from toJson, which is
        // why this is 32 (not 34).
        final info = OhosDeviceInfo.fromMap(_sampleOhosInfo);
        expect(info.toJson().length, 32);
      });

      test('round-trips through fromMap preserving representative fields', () {
        final original = OhosDeviceInfo.fromMap(_sampleOhosInfo);
        final roundTripped = OhosDeviceInfo.fromMap(original.toJson());

        // BaseDeviceInfo has no value equality, so compare across string /
        // int / bool field types rather than using ==.
        expect(roundTripped.brand, original.brand);
        expect(roundTripped.osFullName, original.osFullName);
        expect(roundTripped.productModel, original.productModel);
        expect(roundTripped.sdkApiVersion, original.sdkApiVersion);
        expect(roundTripped.buildVersion, original.buildVersion);
        expect(roundTripped.isPhysicalDevice, original.isPhysicalDevice);
      });

      test('emits the field values it was parsed from', () {
        final info = OhosDeviceInfo.fromMap(_sampleOhosInfo);
        final json = info.toJson();

        expect(json['brand'], 'DEMO-brand');
        expect(json['osFullName'], 'DEMO-osFullName');
        expect(json['majorVersion'], 5);
        expect(json['isPhysicalDevice'], isTrue);
      });
    });
  });

  group('$OhosAccessUDIDInfo', () {
    group('fromMap', () {
      test('parses serial and udid', () {
        final info = OhosAccessUDIDInfo.fromMap(<String, dynamic>{
          'serial': 'ABC123',
          'udid': 'UDID-456',
        });

        expect(info.serial, 'ABC123');
        expect(info.udid, 'UDID-456');
      });

      test('falls back to empty strings when fields are missing', () {
        final info = OhosAccessUDIDInfo.fromMap(<String, dynamic>{});

        expect(info.serial, isEmpty);
        expect(info.udid, isEmpty);
      });
    });

    group('toJson', () {
      test('serializes serial and udid', () {
        final info = OhosAccessUDIDInfo.fromMap(<String, dynamic>{
          'serial': 'ABC123',
          'udid': 'UDID-456',
        });

        expect(info.toJson(), <String, dynamic>{
          'serial': 'ABC123',
          'udid': 'UDID-456',
        });
      });

      test('round-trips through fromMap', () {
        final original = OhosAccessUDIDInfo.fromMap(<String, dynamic>{
          'serial': 'ABC123',
          'udid': 'UDID-456',
        });

        final roundTripped =
            OhosAccessUDIDInfo.fromMap(original.toJson());

        expect(roundTripped.serial, original.serial);
        expect(roundTripped.udid, original.udid);
      });

      test('has exactly two keys', () {
        final info = OhosAccessUDIDInfo.fromMap(<String, dynamic>{
          'serial': 's',
          'udid': 'u',
        });

        expect(info.toJson().length, 2);
      });
    });
  });
}
