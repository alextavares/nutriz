#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.nutritracker.app"
SERIAL="${ADB_SERIAL:-}"
BUILD_MODE="debug" # or release
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# Detect environment (Git Bash/Cygwin vs Linux)
UNAME=$(uname -s 2>/dev/null || echo unknown)
IS_MINGW=0
if echo "$UNAME" | grep -qiE 'mingw|msys|cygwin'; then IS_MINGW=1; fi

if [[ $IS_MINGW -eq 1 ]]; then
  # Use Windows Android SDK if available
  WIN_SDK="/c/Users/${USERNAME:-$USER}/AppData/Local/Android/Sdk"
  if [[ -d "$WIN_SDK" ]]; then
    export ANDROID_SDK_ROOT="$WIN_SDK"
    export ANDROID_HOME="$WIN_SDK"
  else
    # Fallback to project-local SDK
    export ANDROID_SDK_ROOT="$ROOT_DIR/.tooling/android-sdk"
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
  fi
else
  # Linux/WSL: use project-local SDK to avoid host conflicts
  export ANDROID_SDK_ROOT="$ROOT_DIR/.tooling/android-sdk"
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
fi
TMP_LOG="$(mktemp -t nutri_install.XXXXXX || echo /tmp/nutri_install.log)"

FLUTTER_INVOKE=("$(dirname "$0")/flutter_invoke.sh")

usage() {
  cat <<EOF
Usage: $0 [--release] [--serial <adb-serial>] [--fresh]

Builds the Flutter APK and installs it on a connected device/emulator.
Environment:
  ADB_SERIAL  If set, used as default device serial (overridden by --serial).
  INITIAL_ROUTE  If set, passed to Flutter as --dart-define=INITIAL_ROUTE.
  UI_TAG        If set, passed as --dart-define=UI_TAG (always shown in header).
EOF
}

FRESH=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --release) BUILD_MODE="release"; shift;;
    --serial) SERIAL="$2"; shift 2;;
    --fresh) FRESH=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

# Ensure flutter shim exists
if [ ! -x "${FLUTTER_INVOKE[0]}" ]; then
  echo "Error: ${FLUTTER_INVOKE[0]} not found or not executable." >&2
  exit 1
fi
if ! command -v adb >/dev/null 2>&1; then
  echo "Error: adb not found in PATH" >&2
  exit 1
fi

echo "==> flutter pub get"
"${FLUTTER_INVOKE[@]}" pub get

# Patch android/local.properties to ensure Gradle uses the correct SDK/Flutter
LP="$ROOT_DIR/android/local.properties"
RESTORE_LP=""
if [[ -f "$LP" ]]; then
  RESTORE_LP="${LP}.bak.$(date +%s)"
  cp "$LP" "$RESTORE_LP"
fi
if [[ $IS_MINGW -eq 1 ]]; then
  # Windows paths with backslashes for Gradle
  FLUTTER_SDK_WIN="C:\\Users\\${USERNAME:-$USER}\\AppData\\Local\\flutter\\flutter"
  if [[ ! -d "/c/Users/${USERNAME:-$USER}/AppData/Local/flutter/flutter" ]]; then
    # Fallback to project-local flutter path (not ideal on Windows, but try)
    FLUTTER_SDK_WIN=$(printf '%s' "$ROOT_DIR/.tooling/flutter" | sed 's|/|\\\\|g')
  fi
  SDK_DIR_WIN=$(printf '%s' "$ANDROID_SDK_ROOT" | sed 's|/|\\\\|g')
  {
    echo "flutter.sdk=$FLUTTER_SDK_WIN"
    echo "sdk.dir=$SDK_DIR_WIN"
    if [[ -f "$RESTORE_LP" ]]; then
      grep -v -E '^(sdk\.dir|flutter\.sdk)=' "$RESTORE_LP" || true
    fi
  } > "$LP"
else
  {
    echo "flutter.sdk=$ROOT_DIR/.tooling/flutter"
    echo "sdk.dir=$ANDROID_SDK_ROOT"
    if [[ -f "$RESTORE_LP" ]]; then
      grep -v -E '^(sdk\.dir|flutter\.sdk)=' "$RESTORE_LP" || true
    fi
  } > "$LP"
fi

# Compose build metadata
HASH=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)
TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo unknown)
# Date-based build ID (e.g., 0822-1912Z) as a fallback when HASH is unknown
ID=$(date -u +%m%d-%H%MZ 2>/dev/null || echo NA)
APP_VERSION=$(awk '/^version:/{print $2}' "$ROOT_DIR/pubspec.yaml" 2>/dev/null || echo 0.0.0+0)

DEFINES=(
  --dart-define=BUILD_HASH="$HASH"
  --dart-define=BUILD_TIME="$TIME"
  --dart-define=APP_VERSION="$APP_VERSION"
  --dart-define=BUILD_ID="$ID"
)

# Optional defines for routing and UI tagging
if [[ -n "${INITIAL_ROUTE:-}" ]]; then
  DEFINES+=( --dart-define=INITIAL_ROUTE="$INITIAL_ROUTE" )
fi
if [[ -n "${UI_TAG:-}" ]]; then
  DEFINES+=( --dart-define=UI_TAG="$UI_TAG" )
else
  # Default a recognizable tag during development
  DEFINES+=( --dart-define=UI_TAG="UIv2" )
fi

if [[ "$BUILD_MODE" == "release" ]]; then
  echo "==> flutter build apk --release"
  "${FLUTTER_INVOKE[@]}" build apk --release "${DEFINES[@]}"
  APK="build/app/outputs/flutter-apk/app-release.apk"
else
  echo "==> flutter build apk --debug"
  "${FLUTTER_INVOKE[@]}" build apk --debug "${DEFINES[@]}"
  APK="build/app/outputs/flutter-apk/app-debug.apk"
fi

if [[ ! -f "$APK" ]]; then
  echo "Error: APK not found at $APK" >&2
  exit 1
fi

ADB_ARGS=()
if [[ -n "$SERIAL" ]]; then
  ADB_ARGS+=( -s "$SERIAL" )
fi

echo "==> adb install -r $APK"
# Try install; if signature mismatch, uninstall and retry automatically
set +e
if [[ $FRESH -eq 1 ]]; then
  adb "${ADB_ARGS[@]}" uninstall "$APP_ID" >/dev/null 2>&1 || true
fi
adb "${ADB_ARGS[@]}" install -r "$APK" 2>&1 | tee "$TMP_LOG"
rc=${PIPESTATUS[0]}
set -e
if [[ $rc -ne 0 ]] && rg -q "INSTALL_FAILED_UPDATE_INCOMPATIBLE" "$TMP_LOG" 2>/dev/null; then
  echo "Install failed due to signature mismatch. Uninstalling and retrying..." >&2
  adb "${ADB_ARGS[@]}" uninstall "$APP_ID" || true
  adb "${ADB_ARGS[@]}" install -r "$APK"
fi
rm -f "$TMP_LOG" || true

# Restore local.properties if it existed
if [[ -n "$RESTORE_LP" && -f "$RESTORE_LP" ]]; then
  mv "$RESTORE_LP" "$LP" || true
fi

echo "==> Launching $APP_ID"
adb "${ADB_ARGS[@]}" shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null
echo "Done."
