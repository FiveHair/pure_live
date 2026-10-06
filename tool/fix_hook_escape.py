# -*- coding: utf-8 -*-
import io

p = r"D:\DEV\media-kit-predidit\media_kit\hook\build.dart"
s = io.open(p, encoding="utf-8").read()
bad = "final ccPath = cc.replaceAll(r'', '/');"
good = "final ccPath = cc.replaceAll(r'\\', '/');"
if bad in s:
    s = s.replace(bad, good, 1)
    io.open(p, "w", encoding="utf-8", newline="").write(s)
    print("fixed via file script")
else:
    # 兜底：任何形态的 ccPath 行统一替换
    out = []
    bs = chr(92)
    for line in s.split("\n"):
        if "ccPath = cc.replaceAll" in line:
            indent = line[: len(line) - len(line.lstrip())]
            line = indent + "final ccPath = cc.replaceAll(r'" + bs + bs + "', '/');"
            print("replaced:", line)
        out.append(line)
    io.open(p, "w", encoding="utf-8", newline="").write("\n".join(out))
