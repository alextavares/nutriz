#!/usr/bin/env bash
set -euo pipefail
SCREEN="home"; MODE="dark"; LOCALE=""
NUTRI_SERIAL="${NUTRI_SERIAL:-}"; YAZIO_SERIAL="${YAZIO_SERIAL:-}"
NUTRI_PKG="com.nutritracker.app"; YAZIO_PKG="com.yazio.android"
usage(){ echo "Usage: $0 [--screen <name>] [--mode dark|light] [--locale xx-YY] [--nutri-serial S] [--yazio-serial S]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --screen) SCREEN="$2"; shift 2;;
    --mode) MODE="$2"; shift 2;;
    --nutri-serial) NUTRI_SERIAL="$2"; shift 2;;
    --yazio-serial) YAZIO_SERIAL="$2"; shift 2;;
    --locale) LOCALE="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done
if ! command -v adb >/dev/null 2>&1; then echo "adb not found" >&2; exit 1; fi

detect_serials() {
  mapfile -t devs < <(adb devices | awk 'NR>1 && $2=="device"{print $1}')
  for d in "${devs[@]}"; do
    if [[ -z "${NUTRI_SERIAL}" ]]; then
      adb -s "$d" shell pm list packages 2>/dev/null | grep -q "$NUTRI_PKG" && NUTRI_SERIAL="$d" || true
    fi
    if [[ -z "${YAZIO_SERIAL}" ]]; then
      adb -s "$d" shell pm list packages 2>/dev/null | grep -q "$YAZIO_PKG" && YAZIO_SERIAL="$d" || true
    fi
  done
}
set_theme() { local s="$1" v="2"; [[ "$MODE" == "light" ]] && v="1"; adb -s "$s" shell settings put secure ui_night_mode "$v" >/dev/null 2>&1 || true; }
set_locale() {
  local s="$1" l="$2"; [[ -z "$l" ]] && return 0
  adb -s "$s" shell cmd locale set "$l" >/dev/null 2>&1 || true
}
launch_cap() {
  local s="$1" pkg="$2" tag="$3" out="pr_captures/${SCREEN}/${tag}_${MODE}.png"
  mkdir -p "pr_captures/${SCREEN}"
  adb -s "$s" shell am force-stop "$pkg" >/dev/null 2>&1 || true
  adb -s "$s" shell monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || true
  sleep 3
  python3 scripts/adb_ui.py "$s" screencap "$out" || adb -s "$s" shell screencap -p | sed 's/\r$//' > "$out"
  echo "$out"
}
print_locale(){ local s="$1"; echo -n "Locale($s): "; adb -s "$s" shell getprop persist.sys.locale 2>/dev/null || true; adb -s "$s" shell cmd locale 2>/dev/null || true; }

# main
detect_serials
if [[ -z "$NUTRI_SERIAL" || -z "$YAZIO_SERIAL" ]]; then echo "Serials not resolved. Set NUTRI_SERIAL/YAZIO_SERIAL." >&2; exit 1; fi
echo "Using NUTRI_SERIAL=$NUTRI_SERIAL, YAZIO_SERIAL=$YAZIO_SERIAL"
print_locale "$NUTRI_SERIAL" || true
print_locale "$YAZIO_SERIAL" || true
set_locale "$NUTRI_SERIAL" "$LOCALE" || true
set_locale "$YAZIO_SERIAL" "$LOCALE" || true
set_theme "$NUTRI_SERIAL"; set_theme "$YAZIO_SERIAL"
launch_cap "$NUTRI_SERIAL" "$NUTRI_PKG" "nutri_${SCREEN}"
launch_cap "$YAZIO_SERIAL" "$YAZIO_PKG" "yazio_${SCREEN}"
