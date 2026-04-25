#!/bin/bash

# This script handles volume updates and slider interactions.

volume_change() {
  if [ "$INFO" -eq "0" ]; then
    ICON="􀊣"
  elif (( INFO > 0 && INFO <= 29 )); then
    ICON="􀊥"
  elif (( INFO >= 30 && INFO <= 69 )); then
    ICON="􀊧"
  else
    ICON="􀊩"
  fi

  sketchybar --set volume_icon label="$INFO%" icon="$ICON" \
             --set volume_slider slider.percentage=$INFO
}

show_popup() {
  sketchybar --set volume_icon popup.drawing=on
  sleep 2
  FINAL_PERCENTAGE=$(sketchybar --query volume_slider | jq -r ".slider.percentage")
  if [ "$FINAL_PERCENTAGE" -eq "$INFO" ]; then
    sketchybar --set volume_icon popup.drawing=off
  fi
}

mouse_clicked() {
  local popup_drawing
  popup_drawing=$(sketchybar --query volume_icon | jq -r ".popup.drawing")
  if [ "$popup_drawing" = "on" ]; then
    sketchybar --set volume_icon popup.drawing=off \
               --set volume_slider slider.knob.drawing=off
  else
    # Call show_popup to display for 2 seconds and update icon
    show_popup
    sketchybar --set volume_slider slider.knob.drawing=on
  fi
}

# Handle real-time slider drag tracking
monitor_slider_drag() {
  local last_percentage=-1
  local idle_count=0
  
  while true; do
    local current_percentage=$(sketchybar --query volume_slider 2>/dev/null | jq -r ".slider.percentage" 2>/dev/null)
    
    # Validate the percentage value
    if [ -z "$current_percentage" ] || [ "$current_percentage" = "null" ]; then
      sleep 0.2
      continue
    fi
    
    # Only update if percentage actually changed
    if [ "$current_percentage" != "$last_percentage" ]; then
      local int_percentage=$(printf "%.0f" "$current_percentage")
      
      # Clamp percentage between 0-100
      if (( int_percentage < 0 )); then
        int_percentage=0
      elif (( int_percentage > 100 )); then
        int_percentage=100
      fi
      
      # Set volume and update display atomically
      osascript -e "set volume output volume $int_percentage" 2>/dev/null
      
      # Determine icon based on volume level
      if [ "$int_percentage" -eq "0" ]; then
        ICON="􀊣"
      elif (( int_percentage > 0 && int_percentage <= 29 )); then
        ICON="􀊥"
      elif (( int_percentage >= 30 && int_percentage <= 69 )); then
        ICON="􀊧"
      else
        ICON="􀊩"
      fi
      
      # Update UI
      sketchybar --set volume_icon label="$int_percentage%" icon="$ICON" 2>/dev/null
      last_percentage=$current_percentage
      idle_count=0
    else
      # If no change detected, increase idle counter
      ((idle_count++))
      
      # If idle for too long, increase sleep interval (adaptive polling)
      if [ $idle_count -gt 3 ]; then
        sleep 0.3
      else
        sleep 0.1
      fi
      continue
    fi
    
    sleep 0.1
  done
}

case "$SENDER" in
  "mouse.clicked")
    if [ "$NAME" = "volume_slider" ]; then
      # Handle slider clicks/drags - PERCENTAGE is available on click
      if [ -n "$PERCENTAGE" ]; then
        PERCENTAGE=$(printf "%.0f" "$PERCENTAGE")
        if (( PERCENTAGE < 0 )); then
          PERCENTAGE=0
        elif (( PERCENTAGE > 100 )); then
          PERCENTAGE=100
        fi
        osascript -e "set volume output volume $PERCENTAGE"
        sketchybar --set volume_icon label="$PERCENTAGE%"
        show_popup
      fi
    elif [ "$NAME" = "volume_icon" ]; then
      # Handle clicks on volume_icon
      mouse_clicked
    fi
  ;;
  "volume_change") volume_change
  ;;
  "mouse.entered")
    sketchybar --set volume_slider slider.knob.drawing=on
    # Start monitoring slider drag in background
    monitor_slider_drag &
    echo $! > /tmp/sketchybar_volume_monitor.pid
  ;;
  "mouse.exited")
    sketchybar --set volume_slider slider.knob.drawing=off
    # Stop monitoring
    if [ -f /tmp/sketchybar_volume_monitor.pid ]; then
      kill $(cat /tmp/sketchybar_volume_monitor.pid) 2>/dev/null
      rm /tmp/sketchybar_volume_monitor.pid
    fi
  ;;
esac
