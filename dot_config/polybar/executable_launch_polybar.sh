#!/usr/bin/env bash

pkill polybar

# Wait until all polybar processes are fully gone
while pgrep -u "$UID" -x polybar >/dev/null; do
  sleep 0.1
done

sleep 0.2

# Launch one instance per connected monitor
if type "xrandr" > /dev/null; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR="$m" polybar --reload main &
  done
else
  polybar --reload main &
fi
