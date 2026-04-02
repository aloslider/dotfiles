#!/bin/bash
set -euo pipefail

ZSH_PATH="$(which zsh)"

if !(grep -q "^$ZSH_PATH$" /etc/shells;) then
  echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
  echo "Added $ZSH_PATH to /etc/shells"
fi

if [[ "$(getent passwd $USER | cut -d: -f7)" != "$ZSH_PATH" ]]; then
  chsh -s "$ZSH_PATH"
  echo "Set ZSH as default, log out and log back in (or reboot) for the change to take effect"
else
    echo "Default shell is already ZSH"
fi
