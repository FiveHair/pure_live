// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/src/model/android_device_info.dart';
import 'package:flutter_test/flutter_test.dart';

part '../model/android_device_info_fake.dart';

void main() {
  group('$AndroidDeviceInfo fromMap | toMap', () {
    test('fromMap should return $AndroidDeviceInfo with correct values', () {
      final androidDeviceInfo = AndroidDeviceInfo.fromMap(
        _fakeAndroidDeviceInfo,
      );

      expect(androidDeviceInfo.id, 'id');
      expect(androidDeviceInfo.host, 'host');
      expect(androidDeviceInfo.tags, 'tags');
      expect(androidDeviceInfo.type, 'type');
      expect(androidDeviceInfo.model, 'model');
      expect(androidDeviceInfo.board, 'board');
      expect(androidDeviceInfo.brand, 'Google');
      expect(androidDeviceInfo.device, 'device');
      expect(androidDeviceInfo.product, 'product');
      expect(androidDeviceInfo.name, "Custom Device Name");
      expect(androidDeviceInfo.display, 'display');
      expect(androidDeviceInfo.hardware, 'hardware');
      expect(androidDeviceInfo.bootloader, 'bootloader');
      expect(androidDeviceInfo.isPhysicalDevice, isTrue);
      expect(androidDeviceInfo.freeDiskSize, 70729949184);
      expect(androidDeviceInfo.totalDiskSize, 113281839104);
      expect(androidDeviceInfo.fingerprint, 'fingerprint');
      expect(androidDeviceInfo.manufacturer, 'manufacturer');
      expect(androidDeviceInfo.supportedAbis, _fakeSupportedAbis);
      expect(androidDeviceInfo.systemFeatures, _fakeSystemFeatures);
      expect(androidDeviceInfo.supported32BitAbis, _fakeSupported32BitAbis);
      expect(androidDeviceInfo.supported64BitAbis, _fakeSupported64BitAbis);
      expect(androidDeviceInfo.version.sdkInt, 16);
      expect(androidDeviceInfo.version.baseOS, 'baseOS');
      expect(androidDeviceInfo.version.previewSdkInt, 30);
      expect(androidDeviceInfo.version.release, 'release');
      expect(androidDeviceInfo.version.codename, 'codename');
      expect(androidDeviceInfo.version.incremental, 'incremental');
      expect(androidDeviceInfo.version.securityPatch, 'securityPatch');
      expect(androidDeviceInfo.isLowRamDevice, false);
      expect(androidDeviceInfo.physicalRamSize, 8192);
      expect(androidDeviceInfo.availableRamSize, 4096);
    });

    test('toMap should return map with correct key and map', () {
      final androidDeviceInfo = AndroidDeviceInfo.fromMap(
        _fakeAndroidDeviceInfo,
      );

      expect(androidDeviceInfo.data, _fakeAndroidDeviceInfo);
    });
  });

  group('$AndroidDeviceInfo.setMockInitialValues', () {
    test('constructs an instance from explicit mock values', () {
      final mockVersion = AndroidBuildVersion.setMockInitialValues(
        codename: 'REL',
        incremental: 'inc',
        previewSdkInt: 0,
        release: '13',
        sdkInt: 33,
      );
      final info = AndroidDeviceInfo.setMockInitialValues(
        version: mockVersion,
        board: 'board',
        bootloader: 'bootloader',
        brand: 'Google',
        device: 'device',
        display: 'display',
        fingerprint: 'fingerprint',
        hardware: 'hardware',
        host: 'host',
        id: 'id',
        manufacturer: 'Google',
        model: 'Pixel',
        product: 'product',
        name: 'Pixel',
        supported32BitAbis: ['armeabi-v7a'],
        supported64BitAbis: ['arm64-v8a'],
        supportedAbis: ['arm64-v8a', 'armeabi-v7a'],
        tags: 'release-keys',
        type: 'user',
        isPhysicalDevice: true,
        freeDiskSize: 1000,
        totalDiskSize: 2000,
        systemFeatures: ['FEATURE_WIFI'],
        isLowRamDevice: false,
        physicalRamSize: 8192,
        availableRamSize: 4096,
      );

      expect(info.brand, 'Google');
      expect(info.model, 'Pixel');
      expect(info.version.sdkInt, 33);
      expect(info.version.codename, 'REL');
      expect(info.supportedAbis, ['arm64-v8a', 'armeabi-v7a']);
      expect(info.isPhysicalDevice, isTrue);
      expect(info.isLowRamDevice, isFalse);
      // The mock must also produce a valid backing data map.
      expect(info.data['brand'], 'Google');
      expect((info.data['version'] as Map)['sdkInt'], 33);
    });

    test('produces a data map that round-trips through fromMap', () {
      final info = AndroidDeviceInfo.setMockInitialValues(
        version: AndroidBuildVersion.setMockInitialValues(
          codename: 'REL',
          incremental: 'inc',
          previewSdkInt: 0,
          release: '13',
          sdkInt: 33,
        ),
        board: 'b',
        bootloader: 'bl',
        brand: 'Google',
        device: 'd',
        display: 'disp',
        fingerprint: 'fp',
        hardware: 'hw',
        host: 'h',
        id: 'i',
        manufacturer: 'Google',
        model: 'm',
        product: 'p',
        name: 'n',
        supported32BitAbis: [],
        supported64BitAbis: [],
        supportedAbis: [],
        tags: 't',
        type: 'user',
        isPhysicalDevice: false,
        freeDiskSize: 0,
        totalDiskSize: 0,
        systemFeatures: [],
        isLowRamDevice: true,
        physicalRamSize: 0,
        availableRamSize: 0,
      );

      final restored = AndroidDeviceInfo.fromMap(info.data);

      expect(restored.brand, info.brand);
      expect(restored.model, info.model);
      expect(restored.isPhysicalDevice, info.isPhysicalDevice);
      expect(restored.isLowRamDevice, info.isLowRamDevice);
      expect(restored.version.sdkInt, info.version.sdkInt);
    });
  });

  group('$AndroidBuildVersion.setMockInitialValues', () {
    test('constructs a version with required + nullable fields', () {
      final version = AndroidBuildVersion.setMockInitialValues(
        codename: 'REL',
        incremental: 'inc',
        previewSdkInt: 0,
        release: '13',
        sdkInt: 33,
      );

      expect(version.sdkInt, 33);
      expect(version.codename, 'REL');
      expect(version.release, '13');
      expect(version.previewSdkInt, 0);
      expect(version.baseOS, isNull);
      expect(version.securityPatch, isNull);
    });

    test('populates the optional baseOS / securityPatch when provided', () {
      final version = AndroidBuildVersion.setMockInitialValues(
        baseOS: 'baseOS',
        codename: 'REL',
        incremental: 'inc',
        previewSdkInt: 1,
        release: '13',
        sdkInt: 33,
        securityPatch: '2023-01-01',
      );

      expect(version.baseOS, 'baseOS');
      expect(version.securityPatch, '2023-01-01');
      expect(version.previewSdkInt, 1);
    });
  });

  group('$AndroidDeviceInfo fromMap boundary scenarios', () {
    test('truncates abi lists at the first null entry', () {
      // _fromList uses takeWhile((item) => item != null): a null mid-list stops
      // collection, and entries after it are dropped.
      final info = AndroidDeviceInfo.fromMap(<String, dynamic>{
        ..._fakeAndroidDeviceInfo,
        'supportedAbis': <dynamic>['arm64-v8a', null, 'x86'],
        'supported32BitAbis': <dynamic>[null, 'x86'],
      });

      expect(info.supportedAbis, ['arm64-v8a']);
      expect(info.supported32BitAbis, <String>[]);
    });

    test('falls back to empty string when name is absent', () {
      final map = Map<String, dynamic>.from(_fakeAndroidDeviceInfo)
        ..remove('name');

      final info = AndroidDeviceInfo.fromMap(map);

      expect(info.name, '');
    });

    test('defaults abi/systemFeatures to empty when keys are missing', () {
      final map = Map<String, dynamic>.from(_fakeAndroidDeviceInfo)
        ..remove('supportedAbis')
        ..remove('supported32BitAbis')
        ..remove('supported64BitAbis')
        ..remove('systemFeatures');

      final info = AndroidDeviceInfo.fromMap(map);

      expect(info.supportedAbis, <String>[]);
      expect(info.supported32BitAbis, <String>[]);
      expect(info.supported64BitAbis, <String>[]);
      expect(info.systemFeatures, <String>[]);
    });
  });
}
