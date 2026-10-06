# -*- coding: utf-8 -*-
import io

p = r"D:\DEV\media-kit-predidit\media_kit\hook\build.dart"
s = io.open(p, encoding="utf-8").read()

old = """    // OpenHarmony (ohos): the OHOS clang from the HarmonyOS SDK needs an
    // explicit target triple and sysroot to find its musl headers.
    final ohosFlags = <String>[];
    if (os == OS.ohos) {
      final cc = input.config.code.cCompiler?.compiler.toFilePath() ?? '';
      final ccPath = cc.replaceAll(r'\\', '/');
      final llvmIdx = ccPath.indexOf('/llvm/bin/');
      if (llvmIdx > 0) {
        final ohosTarget = switch (architecture) {
          Architecture.x64 => 'x86_64-linux-ohos',
          Architecture.arm => 'arm-linux-ohos',
          _ => 'aarch64-linux-ohos',
        };
        ohosFlags.addAll([
          '--target=$ohosTarget',
          '--sysroot=${ccPath.substring(0, llvmIdx)}/sysroot',
        ]);
      }
    }"""

new = """    // OpenHarmony (ohos): the OHOS clang from the HarmonyOS SDK needs an
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
        final ohosTarget = switch (architecture) {
          Architecture.x64 => 'x86_64-linux-ohos',
          Architecture.arm => 'arm-linux-ohos',
          _ => 'aarch64-linux-ohos',
        };
        ohosFlags.addAll([
          '--target=$ohosTarget',
          '--sysroot=${ccPath.substring(0, llvmIdx)}/sysroot',
        ]);
      }
    }"""

assert old in s, "anchor missing"
s = s.replace(old, new, 1)
io.open(p, "w", encoding="utf-8", newline="").write(s)
print("hook detection fixed")
