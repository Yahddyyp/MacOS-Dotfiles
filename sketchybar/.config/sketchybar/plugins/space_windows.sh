#!/bin/bash

sleep 0.2

# --- Yabai version ---
update_space() {
  space=$1
  apps=$(yabai -m query --windows --space $space | jq -r '.[] | select(."is-minimized" == false and .role == "AXWindow") | .app')
  icon_strip=" "
  if [ "$apps" != "" ]; then
    while read -r app; do
      icon=$($CONFIG_DIR/plugins/icon_map.sh "$app")
      case "$icon_strip" in
      *"$icon"*) : ;;
      *) icon_strip+="$icon " ;;
      esac
    done <<<"$apps"
  else
    icon_strip=" —"
  fi
  sketchybar --set space.$space label="$icon_strip"
}

if [ "$SENDER" = "space_windows_change" ]; then
  for space in $(yabai -m query --spaces | jq '.[].index'); do
    update_space $space
  done
elif [ "$SENDER" = "space_change" ]; then
  update_space $(yabai -m query --spaces --space | jq '.index')
fi

# --- AeroSpace version ---
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
