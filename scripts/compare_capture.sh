#!/usr/bin/env bash
set -euo pipefail
SCREEN="home"; MODE="dark"; LOCALE=""; LAUNCH=1; DELAY=3
NUTRI_SERIAL="${NUTRI_SERIAL:-}"; YAZIO_SERIAL="${YAZIO_SERIAL:-}"
NUTRI_PKG="com.nutritracker.app"; YAZIO_PKG="com.yazio.android"
usage(){ echo "Usage: $0 [--screen <name>] [--mode dark|light] [--locale xx-YY] [--nutri-serial S] [--yazio-serial S] [--no-launch] [--delay <secs>]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --screen) SCREEN="$2"; shift 2;;
    --mode) MODE="$2"; shift 2;;
    --nutri-serial) NUTRI_SERIAL="$2"; shift 2;;
    --yazio-serial) YAZIO_SERIAL="$2"; shift 2;;
    --locale) LOCALE="$2"; shift 2;;
    --no-launch) LAUNCH=0; shift 1;;
    --delay) DELAY="$2"; shift 2;;
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
  # Best-effort device-wide locale (may no-op on newer Android)
  adb -s "$s" shell cmd locale set "$l" >/dev/null 2>&1 || true
}
set_app_locale_for() {
  local s="$1" pkg="$2" l="$3"; [[ -z "$l" ]] && return 0
  # Try per-app locale (Android 13+)
  adb -s "$s" shell cmd locale set-app-locales "$pkg" --locales "$l" >/dev/null 2>&1 || true
  # Fallback no-op if unsupported
}
launch_cap() {
  local s="$1" pkg="$2" tag="$3"
  local out="pr_captures/${SCREEN}/${tag}_${MODE}.png"
  mkdir -p "pr_captures/${SCREEN}"
  if [[ "$LAUNCH" -eq 1 ]]; then
    adb -s "$s" shell am force-stop "$pkg" >/dev/null 2>&1 || true
    adb -s "$s" shell monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || true
  fi
  # Best-effort navigation for certain screens on our app
  if [[ "$tag" == nutri_* ]]; then
    case "$SCREEN" in
      search)
        # Try to tap the 'Buscar' tab label/button
        python3 scripts/adb_ui.py "$s" taptext Buscar >/dev/null 2>&1 || \
        python3 scripts/adb_ui.py "$s" taptext Search >/dev/null 2>&1 || true
        sleep 1
        ;;
    esac
  else
    # For YAZIO, attempt English/Portuguese search label
    if [[ "$SCREEN" == "search" ]]; then
      python3 scripts/adb_ui.py "$s" taptext Search >/dev/null 2>&1 || \
      python3 scripts/adb_ui.py "$s" taptext Buscar >/dev/null 2>&1 || true
      sleep 1
    fi
  fi
  # Final small wait to ensure Flutter settled
  sleep "$DELAY"
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
set_app_locale_for "$NUTRI_SERIAL" "$NUTRI_PKG" "$LOCALE" || true
set_app_locale_for "$YAZIO_SERIAL" "$YAZIO_PKG" "$LOCALE" || true
set_theme "$NUTRI_SERIAL"; set_theme "$YAZIO_SERIAL"
launch_cap "$NUTRI_SERIAL" "$NUTRI_PKG" "nutri_${SCREEN}"
launch_cap "$YAZIO_SERIAL" "$YAZIO_PKG" "yazio_${SCREEN}"
