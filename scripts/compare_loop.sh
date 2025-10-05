#!/usr/bin/env bash
set -euo pipefail

# Simple loop: bring NutriTracker to foreground, wait 30s, capture screenshot
# Usage: scripts/compare_loop.sh [--serial <adb-serial>] [--wait <secs>] [--out <png>]

SERIAL="emulator-5554"
WAIT_SECS=30
OUT="pr_captures/nutritracker_pixel9proxl_5554.png"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --serial) SERIAL="$2"; shift 2;;
    --wait) WAIT_SECS="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    -h|--help)
      echo "Usage: $0 [--serial <adb-serial>] [--wait <secs>] [--out <png>]"; exit 0;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

if ! command -v adb >/dev/null 2>&1; then
  echo "Error: adb not found in PATH" >&2
  exit 1
fi

APP_ID="com.nutritracker.app"

echo "==> Launching $APP_ID on $SERIAL"
adb -s "$SERIAL" shell am force-stop "$APP_ID" || true
adb -s "$SERIAL" shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null

echo "==> Waiting ${WAIT_SECS}s for UI to settle"
sleep "$WAIT_SECS"

echo "==> Capturing to $OUT"
mkdir -p "$(dirname "$OUT")"
python3 scripts/adb_ui.py "$SERIAL" screencap "$OUT"

echo "==> Updated $OUT. Open pr_captures/compare_diary_summary.html to compare."

