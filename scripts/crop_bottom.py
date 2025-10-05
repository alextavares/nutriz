#!/usr/bin/env python3
import sys
from pathlib import Path

def crop_bottom(inp: Path, out: Path):
    try:
        from PIL import Image
    except Exception:
        out.write_bytes(inp.read_bytes())
        return
    im = Image.open(inp)
    w, h = im.size
    left = int(w * 0.04)
    right = int(w * 0.96)
    top = int(h * 0.72)
    bottom = int(h * 0.98)
    if right - left < 20 or bottom - top < 20:
        out.write_bytes(inp.read_bytes())
        return
    im.crop((left, top, right, bottom)).save(out)

def main():
    if len(sys.argv) < 3:
        print("Usage: crop_bottom.py <input.png> <output.png>")
        sys.exit(1)
    inp = Path(sys.argv[1])
    out = Path(sys.argv[2])
    out.parent.mkdir(parents=True, exist_ok=True)
    crop_bottom(inp, out)

if __name__ == "__main__":
    main()
