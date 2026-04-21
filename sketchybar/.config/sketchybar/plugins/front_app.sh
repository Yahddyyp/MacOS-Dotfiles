#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --animate tanh 10 --set "$NAME" label="$INFO" icon="$($CONFIG_DIR/plugins/icon_map.sh "$INFO")"
fi

# --- AeroSpace version (Commented out) ---
# if [ "$SENDER" = "front_app_switched" ]; then
#   # Remove potential quotes from the app name
#   APP_NAME=$(echo "$INFO" | tr -d '"')
#   # Fetch icon from the map
#   ICON=$($HOME/.config/sketchybar/plugins/icon_map.sh "$APP_NAME")
#   sketchybar --animate tanh 10 --set "$NAME" \
#     label="$APP_NAME" \
#     icon="$ICON"
# fi
