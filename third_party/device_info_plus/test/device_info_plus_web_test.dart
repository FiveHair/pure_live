@TestOn('browser')
library;

import 'package:device_info_plus/src/device_info_plus_web.dart';
import 'package:device_info_plus/src/model/web_browser_info.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  group('WebBrowserInfo', () {
    test('WebBrowserInfo from Map with values', () {
      final info = WebBrowserInfo.fromMap({
        'appCodeName': 'CODENAME',
        'appName': 'NAME',
        'appVersion': 'VERSION',
        'deviceMemory': 64,
        'language': 'en',
        'languages': ['en', 'es'],
        'platform': 'PLATFORM',
        'product': 'PRODUCT',
        'productSub': 'PRODUCTSUB',
        'userAgent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0',
        'vendor': 'VENDOR',
        'vendorSub': 'VENDORSUB',
        'hardwareConcurrency': 1,
        'maxTouchPoints': 2,
      });

      expect(info.appName, 'NAME');
      expect(info.browserName, BrowserName.firefox);
    });

    test('WebBrowserInfo from empty map', () {
      final info = WebBrowserInfo.fromMap({});

      expect(info.appName, isNull);
      expect(info.browserName, BrowserName.unknown);
    });
  });

  group('DeviceInfoPlusWebPlugin', () {
    // registerWith / deviceInfo both read html.window.navigator, which is only
    // available in a browser test runner.

    test('registerWith installs the plugin as the platform instance', () {
      // The Registrar argument is ignored by flutter_web_plugins; any instance
      // suffices and the call must not throw.
      DeviceInfoPlusWebPlugin.registerWith(Registrar());

      expect(DeviceInfoPlatform.instance, isA<DeviceInfoPlusWebPlugin>());
    });

    test('deviceInfo() returns a WebBrowserInfo built from the navigator',
        () async {
      final plugin = DeviceInfoPlusWebPlugin(Registrar());

      final result = await plugin.deviceInfo();

      expect(result, isA<WebBrowserInfo>());
    });
  });
}
