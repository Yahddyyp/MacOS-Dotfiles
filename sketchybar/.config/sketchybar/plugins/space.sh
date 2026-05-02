#!/bin/sh

# --- Yabai version ---
# [Yabai version] - Comment out this section and uncomment the AeroSpace version below to switch
if [ "$SELECTED" = true ]; then
  sketchybar --animate tanh 10 --set "$NAME" \
    background.drawing=on \
    background.color=0xffcba6f7 \
    label.color=0xaa2a273f \
    icon.color=0xaa2a273f
else
  sketchybar --animate tanh 10 --set "$NAME" \
    background.drawing=on \
    background.color=0xaa2a273f \
    label.color=0xffcba6f7 \
    icon.color=0xffcba6f7
fi

# [AeroSpace version] 
# # Get the focused workspace - prefer the environment variable from trigger, otherwise query
# FOCUSED_WORKSPACE="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
# # Extract workspace number from NAME (e.g., "space.1" -> "1")
# WORKSPACE_NUM="${NAME##*.}"
# 
# if [ "$FOCUSED_WORKSPACE" = "$WORKSPACE_NUM" ]; then
#   sketchybar --animate tanh 10 --set "$NAME" \
#     background.drawing=on \
#     background.color=0xffcba6f7 \
#     label.color=0xaa2a273f \
#     icon.color=0xaa2a273f
# else
#   sketchybar --animate tanh 10 --set "$NAME" \
#     background.drawing=on \
#     background.color=0xaa2a273f \
#     label.color=0xffcba6f7 \
#     icon.color=0xffcba6f7
# fi
