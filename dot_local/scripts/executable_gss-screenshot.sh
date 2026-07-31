#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCREENSHOTS_DIR="${XDG_PICTURES_DIR:-$(xdg-user-dir PICTURES)}/Screenshots"
mkdir -p "${SCREENSHOTS_DIR}"

MODE="${1:-region}"

case "${MODE}" in
region)
  grim -g "$(slurp -d)" -t ppm -
  ;;
window)
  niri msg action screenshot-window
  sleep 0.5
  wl-paste --type image/png
  ;;
monitor-focused)
  grim -t ppm -o "$(niri msg --json focused-output | jq --raw-output .name)" -
  ;;
monitor-all)
  grim -t ppm -
  ;;
*)
  echo "'${MODE}' is not a supported, aborting!" >&2
  exit 1
  ;;
esac | satty --filename - --output-filename "${SCREENSHOTS_DIR}/screenshot-%+.png"
