#!/bin/bash

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --set $NAME popup.drawing=toggle
else
  DATE_STR="$(date +'%a %d %b  -  %I:%M %p')"
  
  INTERFACE=$(route get default 2>/dev/null | awk '/interface:/ {print $2}')
  if [ -z "$INTERFACE" ]; then
    sketchybar --animate tanh 10 --set $NAME label="$DATE_STR" icon.color=0xfff38ba8
    WIFI_LABEL="Disconnected"
  else
    CURRENT_BYTES=$(netstat -ib -I "$INTERFACE" | awk '/<Link#/ {print $7, $10}')
    CURRENT_IN=$(echo "$CURRENT_BYTES" | awk '{print $1}')
    CURRENT_OUT=$(echo "$CURRENT_BYTES" | awk '{print $2}')
    CURRENT_TIME=$(date +%s)
    
    CACHE_FILE="/tmp/sketchybar_network_speed_cache"
    
    IN_FORMATTED="0 B/s"
    OUT_FORMATTED="0 B/s"
    ICON_COLOR="0xffcba6f7"
    
    if [ -f "$CACHE_FILE" ]; then
      read -r PREV_TIME PREV_IN PREV_OUT < "$CACHE_FILE"
      
      TIME_DIFF=$((CURRENT_TIME - PREV_TIME))
      
      if [ "$TIME_DIFF" -gt 0 ]; then
        IN_DIFF=$((CURRENT_IN - PREV_IN))
        OUT_DIFF=$((CURRENT_OUT - PREV_OUT))
        
        IN_SPEED=$((IN_DIFF / TIME_DIFF))
        OUT_SPEED=$((OUT_DIFF / TIME_DIFF))

        
        if [ "$IN_SPEED" -ge 1048576 ]; then
          IN_FORMATTED=$(echo "scale=1; $IN_SPEED / 1048576" | bc)" MB/s"
        elif [ "$IN_SPEED" -ge 1024 ]; then
          IN_FORMATTED=$(echo "scale=1; $IN_SPEED / 1024" | bc)" KB/s"
        else
          IN_FORMATTED="${IN_SPEED} B/s"
        fi
        
        if [ "$OUT_SPEED" -ge 1048576 ]; then
          OUT_FORMATTED=$(echo "scale=1; $OUT_SPEED / 1048576" | bc)" MB/s"
        elif [ "$OUT_SPEED" -ge 1024 ]; then
          OUT_FORMATTED=$(echo "scale=1; $OUT_SPEED / 1024" | bc)" KB/s"
        else
          OUT_FORMATTED="${OUT_SPEED} B/s"
        fi
      fi
    fi
    echo "$CURRENT_TIME $CURRENT_IN $CURRENT_OUT" > "$CACHE_FILE"
    
    sketchybar --animate tanh 10 --set $NAME label="$DATE_STR" icon.color=$ICON_COLOR

    BAND_CACHE="/tmp/sketchybar_network_band_cache"
    if [ ! -f "$BAND_CACHE" ]; then
       echo "" > "$BAND_CACHE"
    fi
    
    MOD_TIME=$(stat -f %m "$BAND_CACHE" 2>/dev/null || echo 0)
    if [ $((CURRENT_TIME - MOD_TIME)) -gt 60 ]; then
       (
         WIFI_INFO=$(system_profiler SPAirPortDataType 2>/dev/null)
         BAND=$(echo "$WIFI_INFO" | awk '/Current Network Information:/,/Other Local Wi-Fi Networks:/' | awk '/Channel:/ {match($0, /[25]GHz/); print substr($0, RSTART, RLENGTH)}' | head -1)
         if [ "$BAND" = "2GHz" ]; then BAND="2.4GHz"; fi
         echo "$BAND" > "$BAND_CACHE"
       ) &
    fi
    
    BAND=$(cat "$BAND_CACHE" 2>/dev/null)
    if [ -n "$BAND" ]; then
      BAND_LABEL="$BAND"
    else
      BAND_LABEL="Connected"
    fi
    
    WIFI_LABEL="⇣ $IN_FORMATTED  ⇡ $OUT_FORMATTED"
  fi
  
  sketchybar --set date.wifi label="$WIFI_LABEL" \
             --set date.band label="$BAND_LABEL" \
             --set date.week_num label="Week Number: $(date +'%V')" \
             --set date.day_of_year label="Day of Year: $(date +'%j')"
fi
