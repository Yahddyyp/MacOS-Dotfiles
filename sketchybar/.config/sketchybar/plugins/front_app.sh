#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# This script works with both yabai and aerospace as they both support
# the front_app_switched event

# --- Yabai version (Now active) ---
if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --animate tanh 10 --set "$NAME" label="$INFO" icon="$($CONFIG_DIR/plugins/icon_map.sh "$INFO")"
fi

# --- Alternative AeroSpace version (Commented out) ---
# if [ "$SENDER" = "front_app_switched" ]; then
#   APP_NAME="$INFO"
#
#   # Check if we have a valid app name (not empty)
#   if [ -z "$APP_NAME" ] || [ "$APP_NAME" = "" ]; then
#     # No windows open on this workspace - show Finder icon
#     sketchybar --animate tanh 10 --set "$NAME" label="Finder" icon=":finder:"
#   else
#     sketchybar --animate tanh 10 --set "$NAME" label="$APP_NAME" icon="$($CONFIG_DIR/plugins/icon_map.sh "$APP_NAME")"
#   fi
# fi
