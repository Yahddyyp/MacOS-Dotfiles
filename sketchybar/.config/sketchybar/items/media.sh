#!/bin/sh

media_cover=(
  script="$PLUGIN_DIR/media.sh"
  icon=􀑪
  icon.font="CaskaydiaCove Nerd Font:16.0"
  icon.color=0xffcba6f7
  icon.padding_left=10
  icon.padding_right=4
  label.padding_left=6
  label.padding_right=10
  label.color=0xffcdd6f4
  label.font="CaskaydiaCove Nerd Font:Bold:14.0"
  label.max_chars=50
  drawing=off
  update_freq=3
  background.color=0xcc1e1e2e
  background.border_color=0x44cba6f7
  background.border_width=1
  background.corner_radius=8
  background.height=30
)

sketchybar --add item media.cover right \
           --set media.cover "${media_cover[@]}" \
           --subscribe media.cover media_change
