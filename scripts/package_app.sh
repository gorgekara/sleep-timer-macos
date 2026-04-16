#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build"
DIST_DIR="$ROOT_DIR/dist"
APP_NAME="Sleep Timer.app"
APP_DIR="$DIST_DIR/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ZIP_PATH="$DIST_DIR/SleepTimer.zip"

cd "$ROOT_DIR"

swift build -c release

RELEASE_BIN="$BUILD_DIR/arm64-apple-macosx/release/SleepTimerApp"

if [[ ! -f "$RELEASE_BIN" ]]; then
    RELEASE_BIN="$(find "$BUILD_DIR" -type f -path '*/release/SleepTimerApp' | head -n 1)"
fi

if [[ -z "${RELEASE_BIN:-}" || ! -f "$RELEASE_BIN" ]]; then
    echo "Could not find the release binary for SleepTimerApp." >&2
    exit 1
fi

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$ROOT_DIR/AppBundle/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$RELEASE_BIN" "$MACOS_DIR/SleepTimerApp"
chmod +x "$MACOS_DIR/SleepTimerApp"

if [[ -f "$ROOT_DIR/AppBundle/AppIcon.icns" ]]; then
    cp "$ROOT_DIR/AppBundle/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

rm -f "$ZIP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ZIP_PATH"

echo "Created app bundle at: $APP_DIR"
echo "Created zip archive at: $ZIP_PATH"
