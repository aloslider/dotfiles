#!/bin/sh
set -eu

KEY="${1:-${KEY:-}}"

if [ -z "$KEY" ]; then
  echo "usage: $0 <key>   (e.g. m or d)" >&2
  notify-send "Discord toggle" "Missing key (m/d)"
  exit 1
fi

PREV_FOCUS=$(niri msg -j focused-window | jq -r '.id // empty')
WINS=$(niri msg -j windows)
WSS=$(niri msg -j workspaces)
DISCORD_ID=$(printf '%s' "$WINS" | jq -r --arg focus "$PREV_FOCUS" '
  [ .[] | select(.app_id == "discord" or .app_id == "discord-canary") ]
  | (map(select(.id == ($focus | tonumber? // -1))) | .[0].id) //
    (map(select(.app_id == "discord-canary")) | .[0].id) //
    (.[0].id // empty)
')

if [ -z "$DISCORD_ID" ]; then
  notify-send "Discord not found" "No discord or discord-canary window"
  exit 1
fi

# monitor-level shown window
SHOWN_WIN=$(printf '%s' "$WINS" | jq -r --argjson did "$DISCORD_ID" --argjson wss "$WSS" '
  (.[] | select(.id == $did) | .workspace_id) as $wsid
  | ($wss[] | select(.id == $wsid) | .output) as $out
  | ($wss[] | select(.output == $out and .is_active) | .active_window_id // empty)
')

# focus Discord only if needed
if [ "$PREV_FOCUS" != "$DISCORD_ID" ]; then
  niri msg action focus-window --id "$DISCORD_ID"
  sleep 0.05
fi

wtype -M ctrl -M shift -k "$KEY" -m shift -m ctrl
sleep 0.05

# restore what that monitor was showing
if [ -n "${SHOWN_WIN:-}" ] && [ "$SHOWN_WIN" != "$DISCORD_ID" ]; then
  niri msg action focus-window --id "$SHOWN_WIN"
  sleep 0.05
fi

# # restore original global focus
if [ -n "$PREV_FOCUS" ] && [ "$PREV_FOCUS" != "$DISCORD_ID" ] && [ "$PREV_FOCUS" != "${SHOWN_WIN:-}" ]; then
  niri msg action focus-window --id "$PREV_FOCUS"
fi
