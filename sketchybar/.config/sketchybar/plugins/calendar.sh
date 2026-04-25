#!/bin/bash

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --set $NAME popup.drawing=toggle
else
  sketchybar --animate tanh 10 --set $NAME label="$(date +'%a %d %b  -  %I:%M %p')"
  
  WIFI_INFO=$(system_profiler SPAirPortDataType 2>/dev/null)
  BAND=$(echo "$WIFI_INFO" | awk '/Current Network Information:/,/Other Local Wi-Fi Networks:/' | grep "Channel:" | head -1 | grep -o "[25]GHz")
  RATE=$(echo "$WIFI_INFO" | awk '/Current Network Information:/,/Other Local Wi-Fi Networks:/' | grep "Transmit Rate:" | head -1 | awk '{print $3}')
  
  if [ "$BAND" = "2GHz" ]; then BAND="2.4GHz"; fi
  
  if [ -z "$BAND" ] || [ -z "$RATE" ]; then
    WIFI_LABEL="Disconnected"
  else
    WIFI_LABEL="$BAND | ${RATE} Mbps"
  fi
  
  sketchybar --set date.wifi label="$WIFI_LABEL" \
             --set date.week_num label="Week Number: $(date +'%V')" \
             --set date.day_of_year label="Day of Year: $(date +'%j')"
fi
