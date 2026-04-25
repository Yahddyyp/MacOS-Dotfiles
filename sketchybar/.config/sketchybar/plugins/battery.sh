#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
9[0-9] | 100)
  ICON="􀛨"
  ;;
[6-8][0-9])
  ICON="􀺸"
  ;;
[3-5][0-9])
  ICON="􀺶"
  ;;
[1-2][0-9])
  ICON="􀛩"
  ;;
*) ICON="􀛪 " ;;
esac

if [[ "$CHARGING" != "" ]]; then
  ICON="􀋦"
fi

STATE_FILE="/tmp/sketchybar_battery_state"

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
  else
    touch "$STATE_FILE"
  fi
fi

if [ -f "$STATE_FILE" ]; then
  TIME_REMAINING="$(pmset -g batt | grep -o '[0-9]\+:[0-9]\+')"
  if [ "$TIME_REMAINING" != "" ] && [ "$TIME_REMAINING" != "0:00" ]; then
    LABEL="$TIME_REMAINING"
  else
    LABEL="${PERCENTAGE}%"
  fi
else
  LABEL="${PERCENTAGE}%"
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --animate tanh 10 --set "$NAME" icon="$ICON" label="$LABEL"
