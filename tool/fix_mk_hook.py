# -*- coding: utf-8 -*-
import io

p = r"D:\DEV\media-kit-predidit\media_kit\hook\build.dart"
s = io.open(p, encoding="utf-8").read()

# 1) 删除后面的 ohosFlags 定义块（从注释行到 addAll 结束）
start = s.find("    // OpenHarmony (ohos): the OHOS clang from the HarmonyOS SDK needs an")
if start == -1:
    raise SystemExit("ohosFlags block start not found")
end_marker = "          ]);\n      }\n    }\n"
end = s.find(end_marker, start)
if end == -1:
    raise SystemExit("ohosFlags block end not found")
end += len(end_marker)
s = s[:start] + s[end:]

# 2) main 顶部插入 ohosFlags 定义
old_head = """  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }
"""
new_head = """  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    // OpenHarmony (ohos): the OHOS clang from the HarmonyOS SDK needs an
    // explicit target triple and sysroot to find its musl headers.
    // Note: the hosted `hooks` package maps ohos to OS.linux, so detect the
    // HarmonyOS toolchain by the compiler path instead of the OS enum.
    final ohosFlags = <String>[];
    {
      final cc = input.config.code.cCompiler?.compiler.toFilePath() ?? '';
      final ccPath = cc.replaceAll(r'\\', '/');
      final llvmIdx = ccPath.indexOf('/llvm/bin/');
      final isOhosToolchain =
          llvmIdx > 0 && ccPath.contains('openharmony');
      if (isOhosToolchain) {
        final ohosTarget = switch (input.config.code.targetArchitecture) {
          Architecture.x64 => 'x86_64-linux-ohos',
          Architecture.arm => 'arm-linux-ohos',
          _ => 'aarch64-linux-ohos',
        };
        ohosFlags.addAll([
          '--target=$ohosTarget',
          '--sysroot=${ccPath.substring(0, llvmIdx)}/sysroot',
        ]);
      }
    }
"""
assert old_head in s
s = s.replace(old_head, new_head, 1)

# 3) 分支条件改用 ohosFlags
s = s.replace(
    "      } else if (source == 'bundled' &&\n          _ohosFlags.isNotEmpty) {",
    "      } else if (source == 'bundled' && ohosFlags.isNotEmpty) {",
)

io.open(p, "w", encoding="utf-8", newline="").write(s)
print("ok")
