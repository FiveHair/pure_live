# -*- coding: utf-8 -*-
"""
对 hvigor 报出的 "TargetPlatform not exhaustively matched" 位置，
在其 switch 的 '{' 后插入 default: break; 兜底（原穷举下 default 不可达，
仅 TargetPlatform.ohos 命中，走函数后续默认逻辑）。

用法：python tool/patch_exhaustive_switch.py "<hvigor错误输出文件>"
"""
import io
import re
import sys

ERR_PAT = re.compile(r"([\\\w:/.\-]+\.dart):(\d+):\d+: Error: The type 'TargetPlatform' is not exhaustively")


def find_brace_after(s, start):
    """返回 start 之后第一个 '{' 的下标"""
    return s.index("{", start)


def patch(path, line_no):
    s = io.open(path, encoding="utf-8").read()
    lines = s.split("\n")
    # 定位该行的 switch( ，向后在 1-3 行内找 '{' 并在其后插入
    idx0 = sum(len(l) + 1 for l in lines[:line_no - 1])
    window = s[idx0: idx0 + 400]
    m = re.search(r"switch\s*\(", window)
    if not m:
        return False
    try:
        b = find_brace_after(window, m.end())
    except ValueError:
        return False
    abs_b = idx0 + b
    # 已插过则跳过
    if s[abs_b + 1: abs_b + 30].lstrip().startswith("default:"):
        return False
    indent_m = re.match(r"[ \t]*", s[idx0:])
    indent = indent_m.group(0) if indent_m else "      "
    insert = f"\n{indent}default:\n{indent}  break;"
    s = s[:abs_b + 1] + insert + s[abs_b + 1:]
    io.open(path, "w", encoding="utf-8", newline="").write(s)
    return True


def main():
    err_file = sys.argv[1]
    text = io.open(err_file, encoding="utf-8", errors="replace").read()
    patched = 0
    seen = set()
    for m in ERR_PAT.finditer(text):
        path = m.group(1).replace("\\", "/")
        line_no = int(m.group(2))
        key = (path, line_no)
        if key in seen:
            continue
        seen.add(key)
        try:
            if patch(path, line_no):
                patched += 1
        except Exception as e:
            print(f"[ERR] {path}:{line_no} {e}")
    print("patched:", patched)


if __name__ == "__main__":
    main()
