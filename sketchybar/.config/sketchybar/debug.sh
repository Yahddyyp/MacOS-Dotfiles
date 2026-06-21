#!/bin/bash
# Run this when sketchybar stops responding to diagnose the process leak
echo "=== Lua processes (basic) ==="
ps -eo pid,ppid,stat,etime,comm | grep -i lua

echo ""
echo "=== Detailed view of each Lua process ==="
for pid in $(pgrep -f "lua.*sketchybarrc"); do
  echo "--- PID $pid ---"
  ps -p $pid -ww -o pid,ppid,stat,command 2>/dev/null
done

echo ""
echo "=== sketchybar process ==="
ps -p $(pgrep sketchybar) -ww -o pid,ppid,stat,command 2>/dev/null || echo "sketchybar not running"

echo ""
echo "=== Total Lua processes ==="
pgrep -f "lua.*sketchybarrc" | wc -l

echo ""
echo "=== Fork errors in log ==="
grep -c "fork: Resource temporarily unavailable" /opt/homebrew/var/log/sketchybar/sketchybar.err.log 2>/dev/null || echo "0"
