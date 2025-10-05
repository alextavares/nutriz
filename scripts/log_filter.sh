#!/usr/bin/env bash
# Filter Android Logcat for a package with useful Flutter/overflow patterns
set -euo pipefail

PKG="com.nutritracker.app"
SERIAL=""
PATTERN='(RenderFlex|overflowed by|EXCEPTION CAUGHT|relevant error-causing widget|The following assertion was thrown|during layout|I/flutter|E/flutter|AiFoodDetection|Camera)'
ONCE=0
NO_PID=0
OUTFILE=""

usage() {
  echo "Usage: $0 [-p package] [-r regex] [--once] [--no-pid] [--out file] [--serial <adb-serial>]" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--package) PKG="$2"; shift 2;;
    -r|--regex) PATTERN="$2"; shift 2;;
    --once) ONCE=1; shift;;
    --no-pid) NO_PID=1; shift;;
    --out) OUTFILE="$2"; shift 2;;
    -s|--serial) SERIAL="$2"; shift 2;;
    -h|--help) usage;;
    *) echo "Unknown arg: $1" >&2; usage;;
  esac
done

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found in PATH" >&2
  exit 1
fi

PID=""
if [[ "$NO_PID" -eq 0 ]]; then
  PID=$(adb shell pidof -s "$PKG" 2>/dev/null || true)
  if [[ -z "$PID" ]]; then
    echo "[warn] PID not found for '$PKG'. Continuing without --pid (use --no-pid to suppress)." >&2
  else
    echo "[i] Using PID=$PID for package '$PKG'" >&2
  fi
else
  echo "[i] Not filtering by PID (--no-pid)" >&2
fi

args=()
if [[ -n "$SERIAL" ]]; then
  args+=(-s "$SERIAL")
fi
args+=(logcat -v time)
if [[ "$ONCE" -eq 1 ]]; then args+=(-d); fi
if [[ -n "$PID" ]]; then args+=("--pid=$PID"); fi

echo "[i] Running: adb ${args[*]}" >&2

if [[ -n "$OUTFILE" ]]; then
  # Use grep -E -i for case-insensitive matching
  adb "${args[@]}" | grep -E -i "$PATTERN" | tee "$OUTFILE"
else
  adb "${args[@]}" | grep -E -i "$PATTERN"
fi
