#!/bin/sh

if [ "$SENDER" = "front_app_switched" ]; then
  # Use Finder as default if INFO is empty
  [ -z "$INFO" ] && INFO="Finder"

  # Skip update if the app hasn't changed (prevents flicker)
  CURRENT="$(sketchybar --query "$NAME" | jq -r '.label.value // ""')"
  [ "$CURRENT" = "$INFO" ] && exit 0

  sketchybar --animate tanh 5 \
             --set "$NAME" label="$INFO" \
             icon="$($CONFIG_DIR/plugins/icon_map.sh "$INFO")"
fi

# --- Alternative AeroSpace version ---
# if [ "$SENDER" = "front_app_switched" ]; then
#   APP_NAME="$INFO"
#
#   # Fix abbreviated app names from AeroSpace
#   [ "$APP_NAME" = "System" ] && APP_NAME="System Settings"
#
#   # Check if we have a valid app name (not empty)
#   if [ -z "$APP_NAME" ] || [ "$APP_NAME" = "" ]; then
#     # No windows open on this workspace - show Finder icon
#     sketchybar --animate tanh 10 --set "$NAME" label="Finder" icon=":finder:"
#   else
#     sketchybar --animate tanh 10 --set "$NAME" label="$APP_NAME" icon="$($CONFIG_DIR/plugins/icon_map.sh "$APP_NAME")"
#   fi
# fi
