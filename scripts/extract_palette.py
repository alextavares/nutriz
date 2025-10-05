#!/usr/bin/env python3
"""
Extract a simple color palette from reference screenshots using Pillow.
Outputs design/palette_reference.json with top colors per image and a merged set.
Install deps: pip install pillow
"""
import json
import os
from pathlib import Path

try:
    from PIL import Image
except Exception as e:
    print("Pillow not available. Install with: pip install pillow")
    raise


IMAGES = [
    "assets/reference_yazio/yazio_diary.png",
    "assets/reference_yazio/yazio_add_meal_open.png",
    "assets/reference_yazio/yazio_search.png",
    "assets/reference_yazio/yazio_settings.png",
    "assets/reference_yazio/yazio_food_detail.png",
]

OUT = Path("design/palette_reference.json")


def top_colors(path, n=6):
    img = Image.open(path).convert("RGBA")
    # Downscale to speed up
    img.thumbnail((400, 400))
    # Remove transparent pixels
    bg = Image.new("RGBA", img.size, (255, 255, 255, 255))
    bg.paste(img, mask=img.split()[3])
    img = bg.convert("RGB")
    pal = img.convert('P', palette=Image.ADAPTIVE, colors=n)
    palette = pal.getpalette()
    color_counts = sorted(pal.getcolors(), reverse=True)
    results = []
    for count, color_index in color_counts[:n]:
        r = palette[color_index * 3]
        g = palette[color_index * 3 + 1]
        b = palette[color_index * 3 + 2]
        results.append({"hex": f"#{r:02X}{g:02X}{b:02X}", "count": count})
    return results


def main():
    data = {}
    merged = {}
    for p in IMAGES:
        if not os.path.exists(p):
            continue
        colors = top_colors(p, n=8)
        data[p] = colors
        for c in colors:
            merged[c["hex"]] = merged.get(c["hex"], 0) + c["count"]
    merged_sorted = [
        {"hex": k, "score": v} for k, v in sorted(merged.items(), key=lambda x: x[1], reverse=True)
    ]
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump({"byImage": data, "merged": merged_sorted}, f, indent=2)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()

