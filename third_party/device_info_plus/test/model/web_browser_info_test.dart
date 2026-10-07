// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$WebBrowserInfo', () {
    group('fromMap | toMap', () {
      const webBrowserInfoMap = <String, dynamic>{
        'browserName': BrowserName.safari,
        'appCodeName': 'appCodeName',
        'appName': 'appName',
        'appVersion': 'appVersion',
        'deviceMemory': 42.0,
        'language': 'language',
        'languages': ['en', 'es'],
        'platform': 'platform',
        'product': 'product',
        'productSub': 'productSub',
        'userAgent': 'Safari',
        'vendor': 'vendor',
        'vendorSub': 'vendorSub',
        'hardwareConcurrency': 2,
        'maxTouchPoints': 42,
      };

      test('fromMap should return $WebBrowserInfo with correct values', () {
        final webBrowserInfo = WebBrowserInfo.fromMap(webBrowserInfoMap);

        expect(webBrowserInfo.browserName, BrowserName.safari);
        expect(webBrowserInfo.appCodeName, 'appCodeName');
        expect(webBrowserInfo.appName, 'appName');
        expect(webBrowserInfo.appVersion, 'appVersion');
        expect(webBrowserInfo.deviceMemory, 42);
        expect(webBrowserInfo.language, 'language');
        expect(webBrowserInfo.languages, ['en', 'es']);
        expect(webBrowserInfo.platform, 'platform');
        expect(webBrowserInfo.product, 'product');
        expect(webBrowserInfo.productSub, 'productSub');
        expect(webBrowserInfo.userAgent, 'Safari');
        expect(webBrowserInfo.vendor, 'vendor');
        expect(webBrowserInfo.vendorSub, 'vendorSub');
        expect(webBrowserInfo.hardwareConcurrency, 2);
        expect(webBrowserInfo.maxTouchPoints, 42);
      });

      test('toMap should return map with correct key and map', () {
        final webBrowserInfo = WebBrowserInfo.fromMap(webBrowserInfoMap);
        expect(webBrowserInfo.data, webBrowserInfoMap);
      });
    });

    group('browserName parsing (user-agent → BrowserName)', () {
      // Pairs of (BrowserName, representative user-agent substring) covering
      // every branch of WebBrowserInfo._parseUserAgentToBrowserName().
      const cases = <BrowserName, String>{
        BrowserName.samsungInternet:
            'Mozilla/5.0 (Linux; Android 9; SAMSUNG SM-G955F) '
            'SamsungBrowser/9.4 Chrome/67.0.3396.87 Mobile Safari/537.36',
        BrowserName.opera:
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) '
            'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 '
            'Safari/537.36 OPR/57.0.3098.106',
        BrowserName.msie:
            'Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; .NET4.0C; '
            'rv:11.0) like Gecko',
        BrowserName.edge:
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/79.0.3945.74 Safari/537.36 Edg/79.0.309.43',
        BrowserName.chrome:
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like '
            'Gecko) Ubuntu Chromium/66.0.3359.181 Chrome/66.0.3359.181 '
            'Safari/537.36',
        BrowserName.firefox:
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 '
            'Firefox/61.0',
        // Note: Safari intentionally placed after Chrome to also cover the
        // Chrome-vs-Safari ordering branch (Chrome UA contains "Safari").
        BrowserName.safari:
            'Mozilla/5.0 (iPhone; CPU iPhone OS 11_4 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.0 Mobile/15E148 '
            'Safari/604.1',
      };

      for (final entry in cases.entries) {
        test('parses ${entry.key} from its user-agent', () {
          final info = WebBrowserInfo.fromMap({'userAgent': entry.value});
          expect(info.browserName, entry.key);
        });
      }

      test('chrome is preferred over safari when both substrings match', () {
        // A Chrome UA also contains "Safari"; the parser must report Chrome.
        const chromeUa =
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/100.0 Safari/537.36';
        expect(
          WebBrowserInfo.fromMap({'userAgent': chromeUa}).browserName,
          BrowserName.chrome,
        );
      });
    });

    group('browserName boundary & null scenarios', () {
      test('returns unknown when userAgent is null', () {
        expect(
          WebBrowserInfo.fromMap({}).browserName,
          BrowserName.unknown,
        );
      });

      test('returns unknown when userAgent is empty', () {
        expect(
          WebBrowserInfo.fromMap({'userAgent': ''}).browserName,
          BrowserName.unknown,
        );
      });

      test('returns unknown when userAgent has no recognized token', () {
        expect(
          WebBrowserInfo.fromMap({'userAgent': 'curl/7.68.0'}).browserName,
          BrowserName.unknown,
        );
      });

      test('edg variant matching Microsoft Edge (legacy "Edge/")', () {
        const edgeLegacyUa =
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 Edge/16.16299';
        expect(
          WebBrowserInfo.fromMap({'userAgent': edgeLegacyUa}).browserName,
          BrowserName.edge,
        );
      });

      test('OPR variant matching Opera', () {
        const operaUa =
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            'OPR/80.0.4170.91';
        expect(
          WebBrowserInfo.fromMap({'userAgent': operaUa}).browserName,
          BrowserName.opera,
        );
      });
    });

    group('public constructor', () {
      test('constructs an instance with all fields set', () {
        final info = WebBrowserInfo(
          appCodeName: 'Mozilla',
          appName: 'Netscape',
          appVersion: '5.0',
          deviceMemory: 8,
          language: 'en',
          languages: ['en', 'es'],
          platform: 'Win32',
          product: 'Gecko',
          productSub: '20030107',
          userAgent: 'Mozilla/5.0 Chrome/100 Safari/537.36',
          vendor: 'Google Inc.',
          vendorSub: '',
          maxTouchPoints: 0,
          hardwareConcurrency: 8,
        );

        expect(info.appCodeName, 'Mozilla');
        expect(info.appName, 'Netscape');
        expect(info.deviceMemory, 8);
        expect(info.languages, ['en', 'es']);
        expect(info.browserName, BrowserName.chrome);
      });

      test('constructs with all-null fields and reports unknown', () {
        final info = WebBrowserInfo(
          appCodeName: null,
          appName: null,
          appVersion: null,
          deviceMemory: null,
          language: null,
          languages: null,
          platform: null,
          product: null,
          productSub: null,
          userAgent: null,
          vendor: null,
          vendorSub: null,
          maxTouchPoints: null,
          hardwareConcurrency: null,
        );

        expect(info.userAgent, isNull);
        expect(info.browserName, BrowserName.unknown);
      });
    });
  });
}
