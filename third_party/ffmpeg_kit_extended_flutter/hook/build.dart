// 鸿蒙移植占位 hook：ffmpeg_kit 官方产物不支持 ohos（录制功能后续适配）。
// 走标准 build 协议但不产出任何 asset；运行时录制相关功能在 ohos 上禁用。
import 'package:hooks/hooks.dart';

Future<void> main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    // no assets for ohos
  });
}
