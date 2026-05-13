#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="My Screensaver.app"
APP_DIR="/tmp/my-screensaver-build/$APP_NAME"
INSTALL_APP_DIR="$HOME/Applications/$APP_NAME"
SUPPORT_DIR="$HOME/Library/Application Support/My Screensaver"
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCH_AGENT_ID="com.claramae.myscreensaver.idlewatcher"
LAUNCH_AGENT_PLIST="$LAUNCH_AGENT_DIR/$LAUNCH_AGENT_ID.plist"

rm -rf "/tmp/my-screensaver-build"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp -X "$ROOT_DIR/AppWrapper/Info.plist" "$APP_DIR/Contents/Info.plist"
cp -X "$ROOT_DIR/index.html" "$APP_DIR/Contents/Resources/index.html"
cp -X "$ROOT_DIR/styles.css" "$APP_DIR/Contents/Resources/styles.css"
cp -X "$ROOT_DIR/script.js" "$APP_DIR/Contents/Resources/script.js"

clang \
  -fobjc-arc \
  -framework Cocoa \
  -framework WebKit \
  -framework ApplicationServices \
  -o "$APP_DIR/Contents/MacOS/MyScreensaverApp" \
  "$ROOT_DIR/AppWrapper/main.m"

xattr -cr "$APP_DIR" 2>/dev/null || true
codesign --force --deep --sign - "$APP_DIR"

mkdir -p "$HOME/Applications"
rm -rf "$INSTALL_APP_DIR"
cp -R "$APP_DIR" "$INSTALL_APP_DIR"
xattr -cr "$INSTALL_APP_DIR" 2>/dev/null || true

mkdir -p "$SUPPORT_DIR" "$LAUNCH_AGENT_DIR"
cp "$ROOT_DIR/IdleWatcher/my-screensaver-watch.sh" "$SUPPORT_DIR/my-screensaver-watch.sh"
chmod +x "$SUPPORT_DIR/my-screensaver-watch.sh"
cp "$ROOT_DIR/IdleWatcher/$LAUNCH_AGENT_ID.plist" "$LAUNCH_AGENT_PLIST"

launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT_PLIST" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT_PLIST"
launchctl enable "gui/$(id -u)/$LAUNCH_AGENT_ID"

echo "Installed $INSTALL_APP_DIR"
echo "Loaded $LAUNCH_AGENT_PLIST"
