#!/bin/sh

APP_FILE="/tmp/sketchybar_media_app"
PID_FILE="/tmp/sketchybar_media_pid"

if [ -f "$APP_FILE" ]; then
  APP="$(cat "$APP_FILE" 2>/dev/null)"
  if [ -n "$APP" ]; then
    /usr/bin/open -b "$APP" 2>/dev/null && exit 0
  fi
fi

if [ -f "$PID_FILE" ]; then
  PID="$(cat "$PID_FILE" 2>/dev/null)"
  if [ -n "$PID" ]; then
    osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $PID) to true" 2>/dev/null && exit 0
  fi
fi
