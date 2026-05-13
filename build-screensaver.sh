#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUNDLE_NAME="MyScreensaver.saver"
BUNDLE_DIR="$ROOT_DIR/build/$BUNDLE_NAME"
INSTALL_DIR="$HOME/Library/Screen Savers"

rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/Contents/MacOS" "$BUNDLE_DIR/Contents/Resources"

cp "$ROOT_DIR/ScreensaverWrapper/Info.plist" "$BUNDLE_DIR/Contents/Info.plist"
printf "BNDL????" > "$BUNDLE_DIR/Contents/PkgInfo"
cp "$ROOT_DIR/index.html" "$BUNDLE_DIR/Contents/Resources/index.html"
cp "$ROOT_DIR/styles.css" "$BUNDLE_DIR/Contents/Resources/styles.css"
cp "$ROOT_DIR/script.js" "$BUNDLE_DIR/Contents/Resources/script.js"

clang \
  -fobjc-arc \
  -bundle \
  -framework ScreenSaver \
  -framework WebKit \
  -framework QuartzCore \
  -framework AppKit \
  -o "$BUNDLE_DIR/Contents/MacOS/MyScreensaver" \
  "$ROOT_DIR/ScreensaverWrapper/MyScreensaverView.m"

xattr -cr "$BUNDLE_DIR" 2>/dev/null || true
codesign --force --deep --sign - "$BUNDLE_DIR"

mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/$BUNDLE_NAME"
cp -R "$BUNDLE_DIR" "$INSTALL_DIR/$BUNDLE_NAME"
xattr -dr com.apple.quarantine "$INSTALL_DIR/$BUNDLE_NAME" 2>/dev/null || true
xattr -dr com.apple.provenance "$INSTALL_DIR/$BUNDLE_NAME" 2>/dev/null || true

echo "Installed $INSTALL_DIR/$BUNDLE_NAME"
