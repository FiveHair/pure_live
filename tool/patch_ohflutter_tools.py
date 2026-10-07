# -*- coding: utf-8 -*-
"""
给 oh-flutter (AtomGit) flutter_flutter SDK 打补丁（幂等，可重复执行）：

1. flutter_tools 与 hvigor 插件复制 native assets 到 ohos/entry/libs 时用
   `endsWith('.so')` 过滤，丢弃了 libmpv.so.2 这类带版本号后缀的动态库，
   导致 HAP 内缺 libmpv、运行时黑屏。改为匹配 `.so` 及 `.so.<数字>` 后缀
   （ohos_builder.dart 与 flutter-hvigor-plugin.ts 两处）。
2. bin/internal/dart-sdk-url.ohos 追加 Windows 宿主的 AOT gen_snapshot
   覆盖键：上游配置只列了 darwin-x64，Windows 回退 OBS 默认源会拿到
   3.12.2/kernel 130 的旧 gen_snapshot，release 构建报
   "Invalid kernel binary format version (expected 130, found 138)"。

用法：python patch_ohflutter_tools.py <sdk_path>
补丁后需删除 bin/cache/flutter_tools.stamp 与 flutter_tools.snapshot。
"""
import io
import os
import sys

BUILDER_REL = os.path.join(
    "packages", "flutter_tools", "lib", "src", "ohos", "ohos_builder.dart"
)
HVIGOR_REL = os.path.join(
    "packages", "flutter_tools", "hvigor", "src", "plugin",
    "flutter-hvigor-plugin.ts",
)
DART_SDK_URL_REL = os.path.join("bin", "internal", "dart-sdk-url.ohos")

BUILDER_OLD = """      for (final FileSystemEntity entity in nativeAssetsArchDir.listSync()) {
        if (entity is File && entity.path.endsWith('.so')) {"""
BUILDER_NEW = """      for (final FileSystemEntity entity in nativeAssetsArchDir.listSync()) {
        // patched: also copy versioned libs like libmpv.so.2
        final RegExp soPattern = RegExp(r'\\.so(\\.\\d+)?$');
        if (entity is File && soPattern.hasMatch(entity.basename)) {"""

HVIGOR_OLD = """          for (const file of files) {
            if (file.endsWith('.so')) {"""
HVIGOR_NEW = """          for (const file of files) {
            // patched: also copy versioned libs like libmpv.so.2
            if (/\\.so(\\.\\d+)?$/.test(file)) {"""

GEN_SNAPSHOT_BASE = (
    "https://atomgit.com/oh-flutter/flutter_flutter/releases/download/"
    "3.47.4-ohos-1.0.4"
)
GEN_SNAPSHOT_KEYS = [
    "ohos-arm64-release/windows-x64.zip",
    "ohos-arm64-profile/windows-x64.zip",
]

# release/profile 引擎 har 指向 3.47.5：1.0.4 的 windows gen_snapshot 是官方
# 3.13.3 构建（snapshot hash 4459fbb…），与 1.0.4 引擎 har（ohos 定制构建
# dba0cb…）不配套，AOT 启动即 "Wrong full snapshot version" 白屏；
# 3.47.5 的引擎 har 恰为官方 hash 构建，与该 gen_snapshot 配套。
HAR_REWRITE = [
    (
        "ohos-arm64-release/artifacts.zip:https://atomgit.com/oh-flutter/"
        "flutter_flutter/releases/download/3.47.4-ohos-1.0.4/"
        "ohos-arm64-release-artifacts.zip",
        "ohos-arm64-release/artifacts.zip:https://atomgit.com/oh-flutter/"
        "flutter_flutter/releases/download/3.47.5-ohos-1.0.0/"
        "ohos-arm64-release-artifacts.zip",
    ),
    (
        "ohos-arm64-profile/artifacts.zip:https://atomgit.com/oh-flutter/"
        "flutter_flutter/releases/download/3.47.4-ohos-1.0.4/"
        "ohos-arm64-profile-artifacts.zip",
        "ohos-arm64-profile/artifacts.zip:https://atomgit.com/oh-flutter/"
        "flutter_flutter/releases/download/3.47.5-ohos-1.0.0/"
        "ohos-arm64-profile-artifacts.zip",
    ),
]


def patch_file(sdk, rel, old, new, label):
    path = os.path.join(sdk, rel)
    if not os.path.isfile(path):
        print("[ERROR] not found:", path)
        sys.exit(1)
    s = io.open(path, encoding="utf-8").read()
    if new in s:
        print("[OK] already patched:", label)
        return
    if old not in s:
        print("[ERROR] anchor missing (SDK updated?):", label)
        sys.exit(1)
    s = s.replace(old, new, 1)
    io.open(path, "w", encoding="utf-8", newline="").write(s)
    print("[OK] patched:", label)


def patch_gen_snapshot_urls(sdk):
    path = os.path.join(sdk, DART_SDK_URL_REL)
    if not os.path.isfile(path):
        print("[ERROR] not found:", path)
        sys.exit(1)
    s = io.open(path, encoding="utf-8").read()
    # 先把上游 1.0.4 的 release/profile har 覆盖行改指 3.47.5（配套
    # windows gen_snapshot），幂等：已是目标行则跳过
    for old, new in HAR_REWRITE:
        if new in s:
            print("[OK] har already 3.47.5:", old.split(":")[0])
            continue
        if old in s:
            s = s.replace(old, new)
            print("[OK] har -> 3.47.5:", old.split(":")[0])
        else:
            print("[WARN] har line not found:", old.split(":")[0])
    changed = False
    for key in GEN_SNAPSHOT_KEYS:
        if key + ":" in s:
            print("[OK] already present:", key)
            continue
        zip_name = key.split("/")[-1]
        entry = "%s:%s/%s\n" % (key, GEN_SNAPSHOT_BASE, zip_name)
        s += entry
        changed = True
        print("[OK] appended:", key)
    if changed or any(new in s for _, new in HAR_REWRITE):
        io.open(path, "w", encoding="utf-8", newline="\n").write(s)


def main():
    sdk = sys.argv[1] if len(sys.argv) > 1 else r"D:\flutter_ohos_347"
    patch_file(sdk, BUILDER_REL, BUILDER_OLD, BUILDER_NEW, "ohos_builder.dart")
    patch_file(sdk, HVIGOR_REL, HVIGOR_OLD, HVIGOR_NEW, "flutter-hvigor-plugin.ts")
    patch_gen_snapshot_urls(sdk)
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
