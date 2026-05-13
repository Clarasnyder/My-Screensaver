#!/usr/bin/env bash
set -euo pipefail

IDLE_SECONDS="${MY_SCREENSAVER_IDLE_SECONDS:-60}"
APP_PATH="$HOME/Applications/My Screensaver.app"

if pgrep -f "$APP_PATH/Contents/MacOS/MyScreensaverApp" >/dev/null 2>&1; then
  exit 0
fi

idle_ns="$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ { value = $NF } END { print value }')"
idle_seconds=$((idle_ns / 1000000000))

if [ "$idle_seconds" -ge "$IDLE_SECONDS" ]; then
  open -gja "$APP_PATH"
fi
