#!/bin/bash
set -euo pipefail

KEY_DIR="$HOME/.config/chezmoi"
KEY_FILE="$KEY_DIR/key.txt"

mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

if (bw status | grep -q '"status": "locked"';) then
    export BW_SESSION=$(bw unlock --raw)
fi

bw sync

bw get item "age-keys" \
  | jq -r '.fields[] | select(.name == "private_key") | .value' \
  > "$KEY_FILE"

if [[ -s "$KEY_FILE" ]]; then
    chmod 600 "$KEY_FILE"
else
    exit 1
fi
