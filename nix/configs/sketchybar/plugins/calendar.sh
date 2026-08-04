#!/bin/bash

export PATH="/run/current-system/sw/bin:/opt/homebrew/bin:/sbin:/usr/sbin:/usr/bin:/bin:$PATH"

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --set $NAME popup.drawing=toggle
else
  DATE_STR="$(date +'%a %d %b  -  %I:%M %p')"

  VPN_ACTIVE=0
  DEFAULT_IFACE=$(/sbin/route get default 2>/dev/null | awk '/interface:/ {print $2}')
  if [[ "$DEFAULT_IFACE" == utun* ]]; then
    VPN_ACTIVE=1
  fi

  # Connectivity check (also feeds the band/status row)
  INTERFACE=$(/sbin/route get default 2>/dev/null | awk '/interface:/ {print $2}')
  if [ -z "$INTERFACE" ]; then
    sketchybar --animate tanh 10 --set $NAME label="$DATE_STR" icon.color=0xfff38ba8
    BAND_LABEL="Disconnected"
  else
    if [ "$VPN_ACTIVE" -eq 1 ]; then
      ICON_COLOR="0xffa6e3a1"
    else
      ICON_COLOR="0xffcba6f7"
    fi
    sketchybar --animate tanh 10 --set $NAME label="$DATE_STR" icon.color=$ICON_COLOR

    BAND_CACHE="/tmp/sketchybar_network_band_cache"
    if [ ! -f "$BAND_CACHE" ]; then
      echo "" >"$BAND_CACHE"
    fi

    MOD_TIME=$(stat -f %m "$BAND_CACHE" 2>/dev/null || echo 0)
    CURRENT_TIME=$(date +%s)
    if [ $((CURRENT_TIME - MOD_TIME)) -gt 300 ]; then
      (
        WIFI_INFO=$(/usr/sbin/system_profiler SPAirPortDataType 2>/dev/null)
        BAND=$(echo "$WIFI_INFO" | awk '/Current Network Information:/,/Other Local Wi-Fi Networks:/' | awk '/Channel:/ {match($0, /[25]GHz/); print substr($0, RSTART, RLENGTH)}' | head -1)
        if [ "$BAND" = "2GHz" ]; then BAND="2.4GHz"; fi
        echo "$BAND" >"$BAND_CACHE"
      ) &
    fi

    BAND=$(cat "$BAND_CACHE" 2>/dev/null)
    if [ -n "$BAND" ]; then
      BAND_LABEL="$BAND"
    else
      BAND_LABEL="Connected"
    fi
  fi

  if [ "$VPN_ACTIVE" -eq 1 ]; then
    VPN_LABEL="Connected"
  else
    VPN_LABEL="Disconnected"
  fi

  UPTIME_OUTPUT=$(uptime)
  UPTIME_LABEL="Up: --"

  if echo "$UPTIME_OUTPUT" | grep -qE "day"; then
    DAYS=$(echo "$UPTIME_OUTPUT" | awk '{print $3}')
    TIME_STR=$(echo "$UPTIME_OUTPUT" | awk '{print $5}' | tr -d ',')
    HOURS=$(echo "$TIME_STR" | cut -d: -f1)
    MINS=$(echo "$TIME_STR" | cut -d: -f2)
    UPTIME_LABEL="Up: ${DAYS}d ${HOURS}h ${MINS}m"
  elif echo "$UPTIME_OUTPUT" | grep -qE "min"; then
    MINS=$(echo "$UPTIME_OUTPUT" | awk '{print $3}' | tr -d ',')
    UPTIME_LABEL="Up: ${MINS}m"
  elif echo "$UPTIME_OUTPUT" | grep -qE ":"; then
    TIME_STR=$(echo "$UPTIME_OUTPUT" | awk '{print $3}' | tr -d ',')
    HOURS=$(echo "$TIME_STR" | cut -d: -f1)
    MINS=$(echo "$TIME_STR" | cut -d: -f2)
    UPTIME_LABEL="Up: ${HOURS}h ${MINS}m"
  else
    UPTIME_LABEL="Up: <1m"
  fi

  sketchybar --set date.band label="$BAND_LABEL" \
    --set date.vpn label="$VPN_LABEL" \
    --set date.uptime label="$UPTIME_LABEL"
fi

