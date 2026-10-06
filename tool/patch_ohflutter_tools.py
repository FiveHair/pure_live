# -*- coding: utf-8 -*-
"""
给 oh-flutter (AtomGit) flutter_flutter SDK 打补丁：

flutter_tools 复制 native assets 到 ohos/entry/libs 时用 `endsWith('.so')`
过滤，丢弃了 libmpv.so.2 这类带版本号后缀的动态库，导致 HAP 内缺 libmpv、
运行时黑屏。改为匹配 `.so` 及 `.so.<数字>` 后缀。

用法：python patch_ohflutter_tools.py <sdk_path>
补丁后需删除 bin/cache/flutter_tools.stamp 与 flutter_tools.snapshot。
"""
import io
import os
import sys

REL = os.path.join(
    "packages", "flutter_tools", "lib", "src", "ohos", "ohos_builder.dart"
)

OLD = """      for (final FileSystemEntity entity in nativeAssetsArchDir.listSync()) {
        if (entity is File && entity.path.endsWith('.so')) {"""
NEW = """      for (final FileSystemEntity entity in nativeAssetsArchDir.listSync()) {
        // patched: also copy versioned libs like libmpv.so.2
        final RegExp soPattern = RegExp(r'\\.so(\\.\\d+)?$');
        if (entity is File && soPattern.hasMatch(entity.basename)) {"""


def main():
    sdk = sys.argv[1] if len(sys.argv) > 1 else r"D:\flutter_ohos_347"
    path = os.path.join(sdk, REL)
    if not os.path.isfile(path):
        print("[ERROR] not found:", path)
        sys.exit(1)
    s = io.open(path, encoding="utf-8").read()
    if NEW in s:
        print("[OK] already patched")
        return
    if OLD not in s:
        print("[ERROR] anchor missing (SDK updated?)")
        sys.exit(1)
    s = s.replace(OLD, NEW, 1)
    io.open(path, "w", encoding="utf-8", newline="").write(s)
    print("[OK] patched:", path)
    for f in (
        "bin/cache/flutter_tools.stamp",
        "bin/cache/flutter_tools.snapshot",
    ):
        p = os.path.join(sdk, f)
        if os.path.exists(p):
            os.remove(p)
            print("[OK] removed", f)


if __name__ == "__main__":
    main()
