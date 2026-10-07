// BaseDeviceInfo (incl. its deprecated toMap()) lives in the
// device_info_plus_platform_interface package, so its deprecation surfaces as
// `deprecated_member_use` (cross-package), not _from_same_package.
// ignore_for_file: deprecated_member_use

import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // BaseDeviceInfo is a pure value object with no external state to clean up;
  // the lifecycle hooks are kept per testing convention to mark a clean
  // boundary between cases.
  setUp(() {});
  tearDown(() {});

  group('$BaseDeviceInfo', () {
    final data = <String, dynamic>{
      'a': 1,
      'b': 'two',
    };
    final info = BaseDeviceInfo(data);

    test('exposes the map passed to the constructor via .data', () {
      expect(info.data, same(data));
      expect(info.data['a'], 1);
      expect(info.data['b'], 'two');
    });

    test('toMap() returns the same map as data (legacy getter)', () {
      // toMap is @Deprecated in favour of .data, but it is still part of the
      // public API and must keep returning the underlying data.
      expect(info.toMap(), same(data));
    });

    test('toString() includes the class name and data', () {
      final str = info.toString();

      expect(str, contains('BaseDeviceInfo'));
      expect(str, contains('data:'));
      expect(str, contains('1'));
      expect(str, contains('two'));
    });
  });
}
