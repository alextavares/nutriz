#!/usr/bin/env python3
import sys
from pathlib import Path

def crop_or_copy(inp: Path, out: Path):
    try:
        from PIL import Image
    except Exception:
        # Pillow not available; just copy
        out.write_bytes(inp.read_bytes())
        return
    im = Image.open(inp)
    w, h = im.size
    # Heuristic crop for the top summary card region
    left = int(w * 0.05)
    right = int(w * 0.95)
    top = int(h * 0.16)
    bottom = int(h * 0.58)
    if bottom > h: bottom = h
    if right > w: right = w
    if left < 0: left = 0
    if top < 0: top = 0
    if right - left < 10 or bottom - top < 10:
        # Degenerate crop; fallback to copy
        out.write_bytes(inp.read_bytes())
        return
    cropped = im.crop((left, top, right, bottom))
    out.parent.mkdir(parents=True, exist_ok=True)
    cropped.save(out)

def main():
    if len(sys.argv) < 3:
        print("Usage: crop_card.py <input.png> <output.png>")
        sys.exit(1)
    inp = Path(sys.argv[1])
    out = Path(sys.argv[2])
    crop_or_copy(inp, out)

if __name__ == "__main__":
    main()

