#!/bin/sh

APP_FILE="/tmp/sketchybar_media_app"
PID_FILE="/tmp/sketchybar_media_pid"

if [ -s "$APP_FILE" ]; then
  APP="$(tr -d '\r\n' <"$APP_FILE" 2>/dev/null)"
  if [ -n "$APP" ]; then
    /usr/bin/open -b "$APP" 2>/dev/null && exit 0
  fi
fi

if [ -s "$PID_FILE" ]; then
  PID="$(tr -d '\r\n' <"$PID_FILE" 2>/dev/null)"
  case "$PID" in
  "" | *[!0-9]*) exit 1 ;;
  esac
  if kill -0 "$PID" 2>/dev/null; then
    /usr/bin/osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $PID) to true" 2>/dev/null && exit 0
  fi
fi
