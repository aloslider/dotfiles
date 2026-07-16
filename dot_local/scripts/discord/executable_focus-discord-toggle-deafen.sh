#!/bin/sh
APP_NAME="discord-canary"
PREV_ID=$(niri msg focused-window 2>/dev/null | awk '
    /Window ID/ { gsub(":", "", $3); print $3; exit }
')
DISCORD_ID=$(niri msg windows 2>/dev/null | awk -v app="$APP_NAME" '
    /^Window ID/ { id = $3; sub(":", "", id) }
    $0 ~ "App ID: \"" app "\"" { print id; exit }
')

if [ -z "$DISCORD_ID" ]; then
    notify-send "Discord not found" "Could not find $APP_NAME window"
    exit 1
fi

niri msg action focus-window --id "$DISCORD_ID"
wtype -M ctrl -M shift -k d -m shift -m ctrl # default discord keybind

if [ -n "$PREV_ID" ]; then
    niri msg action focus-window --id "$PREV_ID"
fi
