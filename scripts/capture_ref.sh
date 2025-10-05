#!/usr/bin/env bash
set -euo pipefail

# Wrapper to run capture_ref.ps1 from WSL
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PS1_PATH_WIN=$(wslpath -w "$SCRIPT_DIR/capture_ref.ps1")

ARGS=( )
OUT_DIR=""
SERIAL=( )
FILE_NAME="ref"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)
      OUT_DIR="$2"; shift 2;;
    --serial)
      SERIAL+=("$2"); shift 2;;
    --file)
      FILE_NAME="$2"; shift 2;;
    *)
      echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

if [[ -n "$OUT_DIR" ]]; then
  OUT_DIR_WIN=$(wslpath -w "$OUT_DIR")
  ARGS+=("-OutDir" "$OUT_DIR_WIN")
fi

if [[ ${#SERIAL[@]} -gt 0 ]]; then
  ARGS+=("-Serial" "${SERIAL[@]}")
fi

ARGS+=("-FileName" "$FILE_NAME")

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PS1_PATH_WIN" ${ARGS[@]}

