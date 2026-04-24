#!/bin/sh

update() {
  APP=""
  for app in "Spotify" "Music"; do
    if pgrep -x "$app" > /dev/null 2>&1; then
      STATE="$(osascript -e "tell application \"$app\" to player state" 2>/dev/null)"
      if [ "$STATE" = "playing" ] || [ "$STATE" = "paused" ]; then
        APP="$app"
        PLAYER_STATE="$STATE"
        break
      fi
    fi
  done

  if [ -n "$APP" ]; then
    TITLE="$(osascript -e "tell application \"$APP\" to name of current track" 2>/dev/null)"
    ARTIST="$(osascript -e "tell application \"$APP\" to artist of current track" 2>/dev/null)"

    LABEL="$ARTIST - $TITLE"
    if [ ${#LABEL} -gt 50 ]; then
      LABEL="$(echo "$LABEL" | cut -c1-47)..."
    fi

    sketchybar --set media.cover drawing=on icon=􀑪 label="$LABEL"
  else
    sketchybar --set media.cover drawing=off
  fi
}

case "$SENDER" in
  "media_change") update ;;
  "mouse.clicked") update ;;
  "routine") update ;;
esac
