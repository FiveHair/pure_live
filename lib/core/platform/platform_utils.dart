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

  /// 鸿蒙原生全屏（横屏/竖屏/跟随系统），对应 MethodCall.ets 的
  /// enterFullscreen：隐藏状态栏与小白条、锁定方向、窗口最大化。
  /// SystemChrome 沉浸模式在鸿蒙上无法完整隐藏小白条，故走原生实现。
  static Future<void> ohosEnterFullscreen(String orientation) async {
    if (!isOhos) return;
    try {
      await _ohosChannel.invokeMethod('enterFullscreen', {'orientation': orientation});
    } catch (_) {}
  }

  /// 退出鸿蒙原生全屏：恢复状态栏/小白条、回竖屏（手机）、恢复窗口
  static Future<void> ohosExitFullscreen() async {
    if (!isOhos) return;
    try {
      await _ohosChannel.invokeMethod('exitFullscreen');
    } catch (_) {}
  }

  /// 鸿蒙仅切换屏幕方向（不动系统栏/窗口状态）。退出全屏流程会先
  /// exitFullscreen 恢复系统栏、再 restorePortrait，若后者复用
  /// enterFullscreen 会把刚恢复的系统栏再藏一次，故方向恢复走本方法。
  static Future<void> ohosSetOrientation(String orientation) async {
    if (!isOhos) return;
    try {
      await _ohosChannel.invokeMethod('setOrientation', {'orientation': orientation});
    } catch (_) {}
  }

  /// 返回桌面（应用转后台不销毁）。move_to_desktop 插件无 ohos 实现，
  /// 主界面返回键在鸿蒙上走原生 moveAbilityToBackground。
  static Future<void> ohosMoveToBackground() async {
    if (!isOhos) return;
    try {
      await _ohosChannel.invokeMethod('moveToBackground');
    } catch (_) {}
  }

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
