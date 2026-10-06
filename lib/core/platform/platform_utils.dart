import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformUtils {
  PlatformUtils._();

  /// 是否鸿蒙系统（ohos 定制 Dart SDK 提供 Platform.isOhos）
  static bool get isOhos => Platform.isOhos;

  /// 是否鸿蒙 PC（2in1 等桌面形态设备）。
  /// 需在启动时调用 [initOhosDeviceType] 后才准确，默认按手机/平板处理
  static bool isOhosPC = false;

  /// 鸿蒙原生能力通道（对应 ohos 工程的 MethodCall.ets）
  static const _ohosChannel = MethodChannel('com.mystyle.purelive/intent');

  /// 启动时识别鸿蒙设备形态：手机/平板对齐 Android 交互，
  /// PC（2in1）对齐 Windows 交互（原生侧 deviceType 判定）
  static Future<void> initOhosDeviceType() async {
    if (!isOhos) {
      return;
    }
    try {
      final desktop = await _ohosChannel.invokeMethod<bool>('checkOhosIsDesktop');
      isOhosPC = desktop ?? false;
    } catch (_) {
      isOhosPC = false;
    }
  }

  static bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS || (isOhos && isOhosPC);

  static bool get isDesktopNotMac =>
      (Platform.isWindows || Platform.isLinux || (isOhos && isOhosPC)) && !Platform.isMacOS;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS || (isOhos && !isOhosPC);

  static bool isMobileWidth(BuildContext context) {
    return MediaQuery.of(context).size.width < 760;
  }

  static bool get isWindows => Platform.isWindows;
  static bool get isMacOS => Platform.isMacOS;
  static bool get isLinux => Platform.isLinux;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;

  static T select<T>({required T desktop, required T mobile}) {
    return isDesktop ? desktop : mobile;
  }
}
