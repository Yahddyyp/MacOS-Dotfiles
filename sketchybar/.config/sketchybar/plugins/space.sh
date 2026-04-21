#!/bin/sh

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

# --- AeroSpace version (Commented out) ---
# if [ "$FOCUSED_WORKSPACE" = "${NAME#*.}" ]; then
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
