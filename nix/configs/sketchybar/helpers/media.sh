#!/bin/sh

export PATH="/run/current-system/sw/bin:/opt/homebrew/bin:$PATH"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

APP=""

for app in "Spotify" "Music"; do
  if pgrep -x "$app" >/dev/null 2>&1; then
    STATE="$(osascript -e "tell application \"$app\" to player state" 2>/dev/null)"

    if [ "$STATE" = "playing" ] || [ "$STATE" = "paused" ]; then
      APP="$app"
      break
    fi
  fi
done

if [ -n "$APP" ]; then
  TITLE="$(osascript -e "tell application \"$APP\" to name of current track" 2>/dev/null)"
  ARTIST="$(osascript -e "tell application \"$APP\" to artist of current track" 2>/dev/null)"

  TITLE="$(printf '%s' "$TITLE" | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null | tr -d '\n\r')"
  ARTIST="$(printf '%s' "$ARTIST" | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null | tr -d '\n\r')"

  LABEL="$ARTIST - $TITLE"

  if [ "${#LABEL}" -gt 50 ]; then
    LABEL="$(printf '%s' "$LABEL" | cut -c1-47)..."
  fi

  sketchybar --set media.cover \
    drawing=on \
    label="$LABEL"
else
  sketchybar --set media.cover drawing=off
fi
