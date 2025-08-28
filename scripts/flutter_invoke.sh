#!/usr/bin/env bash
set -euo pipefail

detect_flutter() {
  local UNAME
  UNAME=$(uname -s 2>/dev/null || echo unknown)

  # 0) On Git Bash/Cygwin environments, prefer Windows flutter.bat
  if echo "$UNAME" | grep -qiE 'mingw|msys|cygwin'; then
    local baseWin="/c/Users/${USERNAME:-$USER}/AppData/Local/flutter/flutter/bin/flutter.bat"
    if [ -f "$baseWin" ]; then
      FLUTTER_INVOKE=("$baseWin")
      return 0
    fi
  fi

  # 1) Project-local Flutter (Linux) if available
  if [ -x ".tooling/flutter/bin/flutter" ]; then
    FLUTTER_INVOKE=(".tooling/flutter/bin/flutter")
    return 0
  fi
  # 2) Native PATH
  if command -v flutter >/dev/null 2>&1; then
    FLUTTER_INVOKE=(flutter)
    return 0
  fi
  # 3) Windows installation via WSL
  local base="/mnt/c/Users/${WINUSER:-$USER}/AppData/Local/flutter/flutter/bin/flutter.bat"
  if [ -f "$base" ]; then
    # Convert to Windows-style path for cmd.exe
    local winpath
    winpath=$(printf '%s' "$base" | sed 's|/|\\\\|g')
    FLUTTER_INVOKE=(cmd.exe /c "$winpath")
    return 0
  fi
  echo "Error: flutter not found (project .tooling, native PATH, or Windows .bat)" >&2
  exit 1
}

detect_flutter
exec "${FLUTTER_INVOKE[@]}" "$@"
