#!/bin/bash

# --- Yabai version (Now active) ---
if [ "$SENDER" = "space_windows_change" ]; then
  space="$(echo "$INFO" | jq -r '.space')"
  apps="$(echo "$INFO" | jq -r '.apps | keys[]')"

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi

  sketchybar --set space.$space label="$icon_strip"
fi

# --- AeroSpace version (Commented out) ---
# AEROSPACE_PATH=$(command -v aerospace)
# ICON_MAP_PATH="$HOME/.config/sketchybar/plugins/icon_map.sh"
# if [ -z "$AEROSPACE_PATH" ]; then
#   [ -f "/opt/homebrew/bin/aerospace" ] && AEROSPACE_PATH="/opt/homebrew/bin/aerospace"
#   [ -f "/usr/local/bin/aerospace" ] && AEROSPACE_PATH="/usr/local/bin/aerospace"
# fi
#
# for sid in 1 2 3 4; do
#   apps=$($AEROSPACE_PATH list-windows --workspace "$sid" --format "%{app-name}")
#   icon_strip=""
#   if [ -n "$apps" ]; then
#     while read -r app; do
#       if [ -n "$app" ]; then
#         icon=$($ICON_MAP_PATH "$app")
#         case "$icon_strip" in
#           *"$icon"*) ;;
#           *) icon_strip+=" $icon" ;;
#         esac
#       fi
#     done <<< "$apps"
#   else
#     icon_strip=" —"
#   fi
#   sketchybar --set space.$sid label="$icon_strip"
# done
