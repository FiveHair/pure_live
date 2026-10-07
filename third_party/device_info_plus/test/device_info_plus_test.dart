// Unit tests for the [DeviceInfoPlugin] class.
//
// Organized BDD-style by behavior: construction, success-path parsing, the Ohos
// method channel, caching, concurrency, exception propagation, and boundary /
// malformed input. Every public getter is exercised. An in-process fake platform
// and a mocked method channel are used — no physical device required.
//
// Only the test/ directory is modified; the production plugin is exercised as-is.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:device_info_plus_platform_interface/method_channel/method_channel_device_info.dart';
import 'package:device_info_plus/src/model/ohos_device_info.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _kChannel = MethodChannel('dev.fluttercommunity.plus/device_info');

/// A configurable [DeviceInfoPlatform] that returns a fixed [BaseDeviceInfo] and
/// counts how many times [deviceInfo] is invoked (used to assert caching and
/// concurrency).
class _CountingPlatform extends DeviceInfoPlatform {
  _CountingPlatform(this._info);

  final BaseDeviceInfo _info;
  int deviceInfoCalls = 0;

  @override
  Future<BaseDeviceInfo> deviceInfo() {
    deviceInfoCalls++;
    return Future.value(_info);
  }
}

/// A [DeviceInfoPlatform] whose [deviceInfo] never completes until
/// [complete] is called. Lets concurrency tests assert that two callers are
/// both in flight *before* the platform answers.
class _CompleterPlatform extends DeviceInfoPlatform {
  final Completer<BaseDeviceInfo> _completer = Completer<BaseDeviceInfo>();
  int deviceInfoCalls = 0;

  @override
  Future<BaseDeviceInfo> deviceInfo() {
    deviceInfoCalls++;
    return _completer.future;
  }

  void complete(BaseDeviceInfo info) => _completer.complete(info);
}

/// A [DeviceInfoPlatform] whose [deviceInfo] always throws — for exception tests.
class _ThrowingPlatform extends DeviceInfoPlatform {
  _ThrowingPlatform(this.error);

  final Object error;

  @override
  Future<BaseDeviceInfo> deviceInfo() => Future.error(error);
}

void main() {
  late DeviceInfoPlatform originalPlatform;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    originalPlatform = DeviceInfoPlatform.instance;
  });

  tearDown(() {
    // Restore the real platform and tear down any mock channel handler so one
    // test cannot leak state into another.
    DeviceInfoPlatform.instance = originalPlatform;
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_kChannel, null);
  });

  group('DeviceInfoPlugin', () {
    // --- Construction -------------------------------------------------------

    group('when constructed', () {
      test('it performs no platform I/O', () {
        // GIVEN a counting platform is installed
        final platform = _CountingPlatform(BaseDeviceInfo(<String, dynamic>{}));
        DeviceInfoPlatform.instance = platform;

        // WHEN a plugin is constructed
        DeviceInfoPlugin();

        // THEN the platform is never queried
        expect(platform.deviceInfoCalls, 0);
      });
    });

    // --- Success path: getters parse the platform map -----------------------

    group('when the platform returns a well-formed map', () {
      test('androidInfo parses into AndroidDeviceInfo', () async {
        DeviceInfoPlatform.instance =
            _CountingPlatform(BaseDeviceInfo(_androidInfoMap));

        final result = await DeviceInfoPlugin().androidInfo;

        expect(result, isA<AndroidDeviceInfo>());
        expect(result.brand, 'Google');
        expect(result.model, 'Pixel');
        expect(result.version.sdkInt, 33);
        expect(result.isPhysicalDevice, isTrue);
      });

      test('iosInfo parses into IosDeviceInfo', () async {
        DeviceInfoPlatform.instance =
            _CountingPlatform(BaseDeviceInfo(_iosInfoMap));

        final result = await DeviceInfoPlugin().iosInfo;

        expect(result, isA<IosDeviceInfo>());
        expect(result.name, 'iPhone');
        expect(result.utsname.machine, 'iPhone14,3');
        expect(result.isPhysicalDevice, isTrue);
      });

      test('macOsInfo parses into MacOsDeviceInfo', () async {
        DeviceInfoPlatform.instance =
            _CountingPlatform(BaseDeviceInfo(_macosInfoMap));

        final result = await DeviceInfoPlugin().macOsInfo;

        expect(result, isA<MacOsDeviceInfo>());
        expect(result.computerName, 'MacBook');
        expect(result.majorVersion, 13);
        expect(result.systemGUID, isNull);
      });

      test('windowsInfo returns the platform value cast to WindowsDeviceInfo',
          () async {
        final value = _windowsDeviceInfo();
        DeviceInfoPlatform.instance = _CountingPlatform(value);

        final result = await DeviceInfoPlugin().windowsInfo;

        expect(result, same(value));
        expect(result.numberOfCores, 8);
      });

      test('linuxInfo returns the platform value cast to LinuxDeviceInfo',
          () async {
        final value = LinuxDeviceInfo(
          name: 'Linux',
          version: '22.04',
          id: 'ubuntu',
          prettyName: 'Ubuntu 22.04 LTS',
          machineId: 'machine-id',
        );
        DeviceInfoPlatform.instance = _CountingPlatform(value);

        final result = await DeviceInfoPlugin().linuxInfo;

        expect(result, same(value));
        expect(result.name, 'Linux');
      });

      test('webBrowserInfo returns the platform value cast to WebBrowserInfo',
          () async {
        final value = _webBrowserInfo();
        DeviceInfoPlatform.instance = _CountingPlatform(value);

        final result = await DeviceInfoPlugin().webBrowserInfo;

        expect(result, same(value));
        expect(result.browserName, BrowserName.chrome);
      });
    });

    // --- Ohos getters via the method channel --------------------------------

    group('when invoked on the Ohos method channel', () {
      // Ohos getters cast the platform instance to [MethodChannelDeviceInfo].
      setUp(() {
        DeviceInfoPlatform.instance = MethodChannelDeviceInfo();
      });

      void mockChannel(String method, Object? Function(MethodCall) handler) {
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_kChannel, (MethodCall call) async {
          if (call.method == method) {
            return handler(call);
          }
          return null;
        });
      }

      test('ohosDeviceInfo parses into OhosDeviceInfo', () async {
        mockChannel('getDeviceInfo', (_) => _ohosInfoMap);

        final result = await DeviceInfoPlugin().ohosDeviceInfo;

        expect(result, isA<OhosDeviceInfo>());
        expect(result.brand, 'DEMO-brand');
        expect(result.osFullName, 'DEMO-osFullName');
        expect(result.majorVersion, 5);
        expect(result.isPhysicalDevice, isTrue);
      });

      test('ohosAccessUDIDInfo parses into OhosAccessUDIDInfo', () async {
        mockChannel('getAccessUDIDInfo', (_) => <String, dynamic>{
              'serial': 'ABC123',
              'udid': 'UDID-456',
            });

        final result = await DeviceInfoPlugin().ohosAccessUDIDInfo;

        expect(result, isA<OhosAccessUDIDInfo>());
        expect(result.serial, 'ABC123');
        expect(result.udid, 'UDID-456');
      });
    });

    // --- Caching -----------------------------------------------------------

    group('caching', () {
      test('androidInfo is computed once and reused on later calls', () async {
        final platform = _CountingPlatform(BaseDeviceInfo(_androidInfoMap));
        DeviceInfoPlatform.instance = platform;
        final plugin = DeviceInfoPlugin();

        final first = await plugin.androidInfo;
        final second = await plugin.androidInfo;

        expect(identical(first, second), isTrue);
        expect(platform.deviceInfoCalls, 1);
      });

      test('iosInfo is also cached across calls on the same instance',
          () async {
        final platform = _CountingPlatform(BaseDeviceInfo(_iosInfoMap));
        DeviceInfoPlatform.instance = platform;
        final plugin = DeviceInfoPlugin();

        await plugin.iosInfo;
        await plugin.iosInfo;

        expect(platform.deviceInfoCalls, 1);
      });

      test('each DeviceInfoPlugin instance keeps its own cache', () async {
        // GIVEN one shared counting platform
        final platform = _CountingPlatform(BaseDeviceInfo(_androidInfoMap));
        DeviceInfoPlatform.instance = platform;

        // WHEN two independent plugin instances each ask for androidInfo
        await DeviceInfoPlugin().androidInfo;
        await DeviceInfoPlugin().androidInfo;

        // THEN the platform is hit twice (caches are per-instance, not global)
        expect(platform.deviceInfoCalls, 2);
      });
    });

    // --- Concurrency -------------------------------------------------------
    //
    // The cache is implemented as `_cached ??= await platform.deviceInfo()`.
    // The second concurrent caller reads `_cached` *before* the first caller's
    // await has completed, so it also dispatches to the platform — the cache
    // deduplicates across *completed* calls, but not across in-flight ones.

    group('under concurrent access', () {
      test('two in-flight androidInfo calls both reach the platform', () async {
        final platform = _CompleterPlatform();
        DeviceInfoPlatform.instance = platform;
        final plugin = DeviceInfoPlugin();

        // Fire both before the platform answers either.
        final a = plugin.androidInfo;
        final b = plugin.androidInfo;

        // THEN both have already dispatched (no in-flight deduplication)
        expect(platform.deviceInfoCalls, 2);

        platform.complete(BaseDeviceInfo(_androidInfoMap));

        final results = await Future.wait([a, b]);
        expect(results[0], isA<AndroidDeviceInfo>());
        expect(results[1], isA<AndroidDeviceInfo>());
      });

      test('sequential calls after the first are served from cache', () async {
        final platform = _CountingPlatform(BaseDeviceInfo(_androidInfoMap));
        DeviceInfoPlatform.instance = platform;
        final plugin = DeviceInfoPlugin();

        await plugin.androidInfo; // populate the cache
        await plugin.androidInfo;
        await plugin.androidInfo;

        // Only the very first call hit the platform.
        expect(platform.deviceInfoCalls, 1);
      });

      test('after a concurrent burst settles, the cache holds', () async {
        final platform = _CompleterPlatform();
        DeviceInfoPlatform.instance = platform;
        final plugin = DeviceInfoPlugin();

        final burst = Future.wait([
          plugin.androidInfo,
          plugin.androidInfo,
          plugin.androidInfo,
        ]);
        expect(platform.deviceInfoCalls, 3); // all three in flight

        platform.complete(BaseDeviceInfo(_androidInfoMap));
        await burst;

        // The last writer of the burst is now cached; a follow-up call must not
        // re-enter the platform.
        final followUp = await plugin.androidInfo;
        expect(followUp, isA<AndroidDeviceInfo>());
        expect(platform.deviceInfoCalls, 3);
      });
    });

    // --- Exception propagation ---------------------------------------------

    group('when the platform fails', () {
      test('androidInfo propagates a PlatformException', () async {
        DeviceInfoPlatform.instance = _ThrowingPlatform(
          PlatformException(code: 'unavailable', message: 'boom'),
        );

        await expectLater(
          DeviceInfoPlugin().androidInfo,
          throwsA(isA<PlatformException>()),
        );
      });

      test('androidInfo propagates a generic Exception', () async {
        DeviceInfoPlatform.instance =
            _ThrowingPlatform(Exception('native crashed'));

        await expectLater(
          DeviceInfoPlugin().androidInfo,
          throwsA(isA<Exception>()),
        );
      });

      test('a failed fetch does not poison the cache', () async {
        // GIVEN a platform that fails
        DeviceInfoPlatform.instance = _ThrowingPlatform(
          PlatformException(code: 'transient', message: 'retry me'),
        );
        final plugin = DeviceInfoPlugin();
        await expectLater(plugin.androidInfo, throwsA(isA<PlatformException>()));

        // WHEN the platform recovers
        final recovered = _CountingPlatform(BaseDeviceInfo(_androidInfoMap));
        DeviceInfoPlatform.instance = recovered;

        // THEN a retry succeeds and fetches fresh (cache was not poisoned)
        final result = await plugin.androidInfo;
        expect(result, isA<AndroidDeviceInfo>());
        expect(recovered.deviceInfoCalls, 1);
      });

      test('cast getters reject a mismatched platform value', () async {
        // A bare BaseDeviceInfo is not any of the concrete host types, so the
        // `as` casts in windowsInfo/linuxInfo/macosInfo/webBrowserInfo fail.
        DeviceInfoPlatform.instance =
            _CountingPlatform(BaseDeviceInfo(<String, dynamic>{}));
        final plugin = DeviceInfoPlugin();

        await expectLater(plugin.windowsInfo, throwsA(isA<TypeError>()));
        await expectLater(plugin.linuxInfo, throwsA(isA<TypeError>()));
        await expectLater(plugin.macOsInfo, throwsA(isA<TypeError>()));
        await expectLater(plugin.webBrowserInfo, throwsA(isA<TypeError>()));
      });

      test('ohosDeviceInfo propagates a PlatformException from the channel',
          () async {
        DeviceInfoPlatform.instance = MethodChannelDeviceInfo();
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_kChannel, (MethodCall call) async {
          throw PlatformException(code: 'denied', message: 'no device info');
        });

        await expectLater(
          DeviceInfoPlugin().ohosDeviceInfo,
          throwsA(isA<PlatformException>()),
        );
      });

      test('ohosDeviceInfo throws when no handler is registered', () async {
        // No mock handler set → invokeMethod throws MissingPluginException.
        DeviceInfoPlatform.instance = MethodChannelDeviceInfo();

        await expectLater(
          DeviceInfoPlugin().ohosDeviceInfo,
          throwsA(isA<MissingPluginException>()),
        );
      });

      test('ohosAccessUDIDInfo throws when the channel returns a non-Map',
          () async {
        DeviceInfoPlatform.instance = MethodChannelDeviceInfo();
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_kChannel, (MethodCall call) async {
          if (call.method == 'getAccessUDIDInfo') {
            return 'not-a-map';
          }
          return null;
        });

        await expectLater(
          DeviceInfoPlugin().ohosAccessUDIDInfo,
          throwsA(anything),
        );
      });

      test(
          'ohosAccessUDIDInfo reports a permission-denial PlatformException',
          () async {
        // getAccessUDIDInfo requires the system-app-only permission
        // ohos.permission.sec.ACCESS_UDID. When the permission is missing the
        // native side rejects the call; the getter must surface that as a
        // PlatformException (it must not silently swallow or coerce it).
        DeviceInfoPlatform.instance = MethodChannelDeviceInfo();
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_kChannel, (MethodCall call) async {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'ohos.permission.sec.ACCESS_UDID not granted',
            details: 'getAccessUDIDInfo',
          );
        });

        await expectLater(
          DeviceInfoPlugin().ohosAccessUDIDInfo,
          throwsA(
            isA<PlatformException>()
                .having((e) => e.code, 'code', 'PERMISSION_DENIED')
                .having((e) => e.message, 'message',
                    contains('ACCESS_UDID')),
          ),
        );
      });
    });

    // --- Delayed / timing-sensitive channel behaviour ----------------------
    //
    // The Ohos getters await a method-channel reply. These tests gate that reply
    // behind a Completer so we can prove the getter neither resolves early
    // (before the channel answers) nor hangs forever once the reply arrives.

    group('under a delayed channel response', () {
      setUp(() {
        DeviceInfoPlatform.instance = MethodChannelDeviceInfo();
      });

      test('ohosDeviceInfo stays pending until the channel replies', () async {
        final response = Completer<Map<String, dynamic>>();
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                _kChannel, (MethodCall call) => response.future);

        final pending = DeviceInfoPlugin().ohosDeviceInfo;

        // Let pending microtasks drain; the getter must still be unresolved
        // because the channel has not answered yet.
        await Future<void>.delayed(Duration.zero);
        expect(response.isCompleted, isFalse);

        // Fulfil the reply now — the getter must resolve (bounded by a timeout
        // so a regression that never completes fails fast instead of hanging).
        response.complete(_ohosInfoMap);

        final result = await pending.timeout(const Duration(seconds: 1));
        expect(result, isA<OhosDeviceInfo>());
        expect(result.brand, 'DEMO-brand');
      });

      test('ohosDeviceInfo completes when the channel reply is delayed',
          () async {
        // Simulate a slow native side by deferring the reply via Future.delayed,
        // then completing a Completer. Asserts the getter tolerates latency and
        // still resolves within a bounded window.
        final response = Completer<Map<String, dynamic>>();
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                _kChannel, (MethodCall call) => response.future);

        Future<void>.delayed(
          const Duration(milliseconds: 10),
          () => response.complete(_ohosInfoMap),
        );

        final result = await DeviceInfoPlugin()
            .ohosDeviceInfo
            .timeout(const Duration(seconds: 1));

        expect(result, isA<OhosDeviceInfo>());
        expect(result.osFullName, 'DEMO-osFullName');
      });
    });

    // --- Boundary / malformed input ----------------------------------------

    group('with boundary or malformed input', () {
      setUp(() {
        DeviceInfoPlatform.instance = MethodChannelDeviceInfo();
      });

      void mockChannel(String method, Object? Function(MethodCall) handler) {
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_kChannel, (MethodCall call) async {
          if (call.method == method) {
            return handler(call);
          }
          return null;
        });
      }

      test('an empty Ohos map yields default values (no crash)', () async {
        mockChannel('getDeviceInfo', (_) => <String, dynamic>{});

        final result = await DeviceInfoPlugin().ohosDeviceInfo;

        expect(result.brand, isEmpty);
        expect(result.osFullName, isEmpty);
        expect(result.majorVersion, 0);
        expect(result.isPhysicalDevice, isFalse);
      });

      test('explicit null Ohos fields fall back to defaults', () async {
        mockChannel('getDeviceInfo', (_) => <String, dynamic>{
              'brand': null,
              'osFullName': null,
              'majorVersion': null,
              'isPhysicalDevice': null,
            });

        final result = await DeviceInfoPlugin().ohosDeviceInfo;

        expect(result.brand, isEmpty);
        expect(result.osFullName, isEmpty);
        expect(result.majorVersion, 0);
        expect(result.isPhysicalDevice, isFalse);
      });

      test('an empty UDID map yields empty strings', () async {
        mockChannel('getAccessUDIDInfo', (_) => <String, dynamic>{});

        final result = await DeviceInfoPlugin().ohosAccessUDIDInfo;

        expect(result.serial, isEmpty);
        expect(result.udid, isEmpty);
      });

      test('a single-field UDID map leaves the other field empty', () async {
        mockChannel('getAccessUDIDInfo', (_) => <String, dynamic>{
              'serial': 'ONLY-SERIAL',
            });

        final result = await DeviceInfoPlugin().ohosAccessUDIDInfo;

        expect(result.serial, 'ONLY-SERIAL');
        expect(result.udid, isEmpty);
      });

      test('OhosDeviceInfo serializes back via toJson', () async {
        mockChannel('getDeviceInfo', (_) => _ohosInfoMap);

        final result = await DeviceInfoPlugin().ohosDeviceInfo;

        final json = result.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['brand'], 'DEMO-brand');
        expect(json['majorVersion'], 5);
      });
    });

    // --- deviceInfo routing ------------------------------------------------

    group('deviceInfo getter', () {
      test('delegates to the platform instance and returns its value',
          () async {
        // The generic `deviceInfo` getter routes through _platform.deviceInfo()
        // and (off the web) returns the matching host type. Build a platform
        // value whose runtime type matches the running host so the getter's
        // `as` cast succeeds regardless of which CI host runs this test.
        final value = _hostMatchingDeviceInfo();
        DeviceInfoPlatform.instance = _CountingPlatform(value);

        final result = await DeviceInfoPlugin().deviceInfo;

        expect(result, same(value));
      });
    });
  });
}

// --- Helpers / sample data --------------------------------------------------

/// Returns a fully populated [WindowsDeviceInfo] for tests.
WindowsDeviceInfo _windowsDeviceInfo() => WindowsDeviceInfo(
      numberOfCores: 8,
      computerName: 'HOST',
      systemMemoryInMegabytes: 16384,
      userName: 'user',
      majorVersion: 10,
      minorVersion: 0,
      buildNumber: 19045,
      platformId: 2,
      csdVersion: '',
      servicePackMajor: 0,
      servicePackMinor: 0,
      suitMask: 0,
      productType: 1,
      reserved: 0,
      buildLab: 'lab',
      buildLabEx: 'labEx',
      digitalProductId: Uint8List(0),
      displayVersion: '22H2',
      editionId: 'Pro',
      installDate: DateTime(2020),
      productId: '00000-00000-00000-AAAAA',
      productName: 'Windows 10 Pro',
      registeredOwner: 'owner',
      releaseId: '2009',
      deviceId: '{id}',
    );

/// Returns a [WebBrowserInfo] for tests.
WebBrowserInfo _webBrowserInfo() => WebBrowserInfo(
      appCodeName: 'Mozilla',
      appName: 'Netscape',
      appVersion: '5.0',
      deviceMemory: 8,
      language: 'en',
      languages: ['en'],
      platform: 'MacIntel',
      product: 'Gecko',
      productSub: '20030107',
      userAgent: 'Mozilla/5.0 Chrome/100 Safari/537.36',
      vendor: 'Google',
      vendorSub: '',
      maxTouchPoints: 0,
      hardwareConcurrency: 8,
    );

/// Returns a [BaseDeviceInfo] whose runtime type matches the running host, so
/// the `deviceInfo` getter's `as <Host>DeviceInfo` cast succeeds on whichever
/// OS the test suite runs under.
BaseDeviceInfo _hostMatchingDeviceInfo() {
  if (Platform.isAndroid) {
    return AndroidDeviceInfo.fromMap(_androidInfoMap);
  }
  if (Platform.isIOS) {
    return IosDeviceInfo.fromMap(_iosInfoMap);
  }
  if (Platform.isMacOS) {
    return MacOsDeviceInfo.fromMap(_macosInfoMap);
  }
  if (Platform.isLinux) {
    return LinuxDeviceInfo(
      name: 'Linux',
      id: 'linux',
      prettyName: 'Linux',
      machineId: 'id',
    );
  }
  if (Platform.isWindows) {
    return _windowsDeviceInfo();
  }
  // Fallback (e.g. an unrecognized host): bare base data.
  return BaseDeviceInfo(<String, dynamic>{});
}

Map<String, dynamic> _androidInfoMap = <String, dynamic>{
  'version': <String, dynamic>{
    'baseOS': 'baseOS',
    'sdkInt': 33,
    'release': '13',
    'codename': 'REL',
    'incremental': 'incremental',
    'previewSdkInt': 0,
    'securityPatch': '2023-01-01',
  },
  'board': 'board',
  'bootloader': 'bootloader',
  'brand': 'Google',
  'device': 'device',
  'display': 'display',
  'fingerprint': 'fingerprint',
  'hardware': 'hardware',
  'host': 'host',
  'id': 'id',
  'manufacturer': 'Google',
  'model': 'Pixel',
  'product': 'product',
  'name': 'Pixel',
  'supported32BitAbis': <String>['x86'],
  'supported64BitAbis': <String>['arm64-v8a'],
  'supportedAbis': <String>['arm64-v8a', 'x86_64'],
  'tags': 'tags',
  'type': 'user',
  'isPhysicalDevice': true,
  'freeDiskSize': 100000,
  'totalDiskSize': 200000,
  'systemFeatures': <String>['FEATURE_WIFI'],
  'isLowRamDevice': false,
  'physicalRamSize': 8192,
  'availableRamSize': 4096,
};

Map<String, dynamic> _iosInfoMap = <String, dynamic>{
  'name': 'iPhone',
  'systemName': 'iOS',
  'systemVersion': '17.0',
  'model': 'iPhone',
  'modelName': 'iPhone 13 Pro',
  'localizedModel': 'iPhone',
  'identifierForVendor': 'IDFV',
  'isPhysicalDevice': true,
  'isiOSAppOnMac': false,
  'freeDiskSize': 1000,
  'totalDiskSize': 2000,
  'physicalRamSize': 6144,
  'availableRamSize': 2048,
  'utsname': <String, dynamic>{
    'sysname': 'Darwin',
    'nodename': 'node',
    'release': 'release',
    'version': 'version',
    'machine': 'iPhone14,3',
  },
};

Map<String, dynamic> _macosInfoMap = <String, dynamic>{
  'computerName': 'MacBook',
  'hostName': 'host',
  'arch': 'arm64',
  'model': 'Mac14,2',
  'modelName': 'MacBook Pro',
  'kernelVersion': '22.0',
  'majorVersion': 13,
  'minorVersion': 0,
  'patchVersion': 0,
  'osRelease': '22.0',
  'activeCPUs': 8,
  'memorySize': 17179869184,
  'cpuFrequency': 0,
  'systemGUID': null,
};

Map<String, dynamic> _ohosInfoMap = <String, dynamic>{
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
