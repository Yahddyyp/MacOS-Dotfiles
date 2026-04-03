#!/bin/sh

update() {
  APP=""
  for app in "Spotify" "Music"; do
    STATE="$(osascript -e "tell application \"$app\" to player state" 2>/dev/null)"
    if [ "$STATE" = "playing" ] || [ "$STATE" = "paused" ]; then
      APP="$app"
      PLAYER_STATE="$STATE"
      break
    fi
  done

  if [ -n "$APP" ]; then
    TITLE="$(osascript -e "tell application \"$APP\" to name of current track" 2>/dev/null)"
    ARTIST="$(osascript -e "tell application \"$APP\" to artist of current track" 2>/dev/null)"

    LABEL="$ARTIST - $TITLE"
    if [ ${#LABEL} -gt 30 ]; then
      LABEL="$(echo "$LABEL" | cut -c1-27)..."
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
