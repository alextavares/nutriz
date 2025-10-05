#!/usr/bin/env bash
set -euo pipefail

DEVICE="${1:-emulator-5556}"
OUT_DIR="${2:-pr_captures}"
mkdir -p "$OUT_DIR"

echo "[info] Target device: $DEVICE"

echo "[step] Reading current wm density..."
DENSITY_RAW=$(adb -s "$DEVICE" shell wm density | tr -d '\r') || true
echo "$DENSITY_RAW" > "$OUT_DIR/$DEVICE.density.txt" || true
# Extract last integer from the output (handles Physical/Override)
DENSITY=$(echo "$DENSITY_RAW" | grep -Eo '[0-9]+' | tail -n1)
if [[ -z "${DENSITY:-}" ]]; then
  echo "[warn] Could not detect density; defaulting to 420"
  DENSITY=420
fi
echo "[info] Using density: $DENSITY dpi"

echo "[step] Saving current wm size..."
SIZE_BEFORE=$(adb -s "$DEVICE" shell wm size | tr -d '\r') || true
echo "$SIZE_BEFORE" > "$OUT_DIR/$DEVICE.size.before.txt"

calc_px() {
  local dp=$1
  local dpi=$2
  # px = round(dp * dpi / 160)
  awk -v dp="$dp" -v dpi="$dpi" 'BEGIN { printf "%d", (dp*dpi/160)+0.5 }'
}

capture_for_dp() {
  local wdp=$1
  local hdp=$2
  local wpx=$(calc_px "$wdp" "$DENSITY")
  local hpx=$(calc_px "$hdp" "$DENSITY")
  echo "[step] Applying wm size ${wdp}dp x ${hdp}dp -> ${wpx}x${hpx}px"
  adb -s "$DEVICE" shell wm size "${wpx}x${hpx}" || true
  sleep 1
  local outpng="$OUT_DIR/${DEVICE}-${wdp}dpx${hdp}dp-${wpx}x${hpx}.png"
  adb -s "$DEVICE" exec-out screencap -p > "$outpng" || true
  echo "[ok] Captured: $outpng"
}

# Targets in dp
capture_for_dp 360 800
capture_for_dp 411 891

echo "[step] Resetting wm size..."
adb -s "$DEVICE" shell wm size reset || true
echo "[step] Resetting wm density (keep physical)"
adb -s "$DEVICE" shell wm density reset || true
SIZE_AFTER=$(adb -s "$DEVICE" shell wm size | tr -d '\r') || true
echo "$SIZE_AFTER" > "$OUT_DIR/$DEVICE.size.after.txt"

HTML="$OUT_DIR/compare_responsive_dp.html"
cat > "$HTML" << HTML
<!doctype html>
<html lang="pt-br">
<head>
  <meta charset="utf-8" />
  <title>NutriTracker — Responsivo por dp ($DEVICE)</title>
  <style>
    body { font-family: system-ui, Arial, sans-serif; background:#111; color:#eee; margin:16px; }
    .row { display:flex; gap:16px; flex-wrap:wrap; }
    figure { margin:0; }
    img { max-width: 42vw; height:auto; border:1px solid #333; border-radius:8px; }
    figcaption { text-align:center; margin-top:6px; color:#ccc; font-size:14px; }
    code { color:#ccc; }
    .meta { margin-bottom:12px; color:#aaa; }
  </style>
</head>
<body>
  <h1>Comparativo por dp — ${DEVICE}</h1>
  <div class="meta">
    <div>Densidade: <code>${DENSITY} dpi</code></div>
    <div>Antes: <code>$(echo "$SIZE_BEFORE" | sed 's/</&lt;/g')</code></div>
    <div>Depois: <code>$(echo "$SIZE_AFTER" | sed 's/</&lt;/g')</code></div>
  </div>
  <div class="row">
    <figure>
      <a href="./${DEVICE}-360dpx800dp-$(calc_px 360 $DENSITY)x$(calc_px 800 $DENSITY).png" target="_blank">
        <img src="./${DEVICE}-360dpx800dp-$(calc_px 360 $DENSITY)x$(calc_px 800 $DENSITY).png" alt="360x800dp" />
      </a>
      <figcaption>360 x 800 dp</figcaption>
    </figure>
    <figure>
      <a href="./${DEVICE}-411dpx891dp-$(calc_px 411 $DENSITY)x$(calc_px 891 $DENSITY).png" target="_blank">
        <img src="./${DEVICE}-411dpx891dp-$(calc_px 411 $DENSITY)x$(calc_px 891 $DENSITY).png" alt="411x891dp" />
      </a>
      <figcaption>411 x 891 dp</figcaption>
    </figure>
  </div>
</body>
</html>
HTML

echo "[done] Generated: $HTML"

