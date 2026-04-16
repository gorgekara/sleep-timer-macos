#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_PATH="$DIST_DIR/Sleep Timer.app"
ZIP_PATH="$DIST_DIR/SleepTimer.zip"
ENTITLEMENTS_PATH="$ROOT_DIR/AppBundle/Release.entitlements"

: "${DEVELOPER_ID_APP_CERT:?Set DEVELOPER_ID_APP_CERT to your Developer ID Application certificate name}"
: "${NOTARY_KEYCHAIN_PROFILE:?Set NOTARY_KEYCHAIN_PROFILE to your notarytool keychain profile name}"

cd "$ROOT_DIR"

zsh "$ROOT_DIR/scripts/package_app.sh"

codesign \
  --force \
  --deep \
  --options runtime \
  --timestamp \
  --entitlements "$ENTITLEMENTS_PATH" \
  --sign "$DEVELOPER_ID_APP_CERT" \
  "$APP_PATH"

xcrun notarytool submit "$APP_PATH" --keychain-profile "$NOTARY_KEYCHAIN_PROFILE" --wait
xcrun stapler staple "$APP_PATH"

rm -f "$ZIP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

codesign --verify --deep --strict --verbose=2 "$APP_PATH"
spctl --assess --type execute --verbose=4 "$APP_PATH"

echo "Signed, notarized, and stapled app at: $APP_PATH"
echo "Refreshed release archive at: $ZIP_PATH"
