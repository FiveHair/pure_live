# -*- coding: utf-8 -*-
"""
修补 vendor 包中对 TargetPlatform 的穷举 switch 缺少 TargetPlatform.ohos 的错误。

oh-flutter 的 Flutter 框架为 TargetPlatform 枚举新增了 ohos 值，
pub 上对 TargetPlatform 使用穷举 switch 表达式的包在鸿蒙 SDK 下编译失败。
策略：在 `TargetPlatform.xxx => value,`（或带引号的字符串值）的 android 分支
旁补一个 ohos 分支，值与 android 相同（鸿蒙交互对齐 Android）。
"""
import io
import os
import re
import sys

ROOTS = sys.argv[1:] or ["third_party"]

# 匹配 TargetPlatform.android => VALUE,   （VALUE 不含逗号，可含括号/引号）
# 也匹配 'TargetPlatform.android' => VALUE（字符串 case 不会出现，忽略）
PAT = re.compile(
    r"(?P<indent>[ \t]+)(?P<case>TargetPlatform\.android)\s*(?P<arrow>=>)\s*(?P<val>[^,\n]+),"
)


def patch_file(path):
    s = io.open(path, encoding="utf-8").read()
    out = []
    changed = 0
    for line in s.split("\n"):
        m = PAT.search(line)
        if m and "TargetPlatform.ohos" not in line:
            indent = m.group("indent")
            val = m.group("val").strip()
            new_line = (
                f"{line}\n{indent}TargetPlatform.ohos => {val},"
            )
            out.append(new_line)
            changed += 1
        else:
            out.append(line)
    if changed:
        io.open(path, "w", encoding="utf-8", newline="").write("\n".join(out))
    return changed


total = 0
for root in ROOTS:
    for dirpath, _, files in os.walk(root):
        if ".dart_tool" in dirpath:
            continue
        for f in files:
            if not f.endswith(".dart"):
                continue
            p = os.path.join(dirpath, f)
            n = patch_file(p)
            if n:
                print(f"[OK] {p}: +{n}")
                total += n
print("total inserted:", total)
