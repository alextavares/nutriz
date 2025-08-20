#!/usr/bin/env bash
set -euo pipefail

if [ -x ".tooling/flutter/bin/dart" ]; then
  exec .tooling/flutter/bin/dart "$@"
fi
if command -v dart >/dev/null 2>&1; then
  exec dart "$@"
fi
BASE="/mnt/c/Users/${WINUSER:-$USER}/AppData/Local/flutter/flutter/bin/cache/dart-sdk/bin/dart.exe"
if [ -f "$BASE" ]; then
  exec "$BASE" "$@"
fi
echo "Error: dart not found (native or Windows SDK)" >&2
exit 1
