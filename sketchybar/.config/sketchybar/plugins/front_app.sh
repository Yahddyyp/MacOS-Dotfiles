#!/bin/sh

if [ "$SENDER" = "front_app_switched" ]; then
  # Use Finder as default if INFO is empty
  [ -z "$INFO" ] && INFO="Finder"

  sketchybar --animate tanh 10 \
             --set "$NAME" label="$INFO" \
             icon="$($CONFIG_DIR/plugins/icon_map.sh "$INFO")"
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
