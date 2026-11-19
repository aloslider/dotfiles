#!/bin/sh
set -eu

name="va-api-hevc-patch"
base="${XDG_CONFIG_HOME:-$HOME/.config}/discord"
marker="VaapiOnNvidiaGPUs"

for asar in "$base"/app-*/resources/app.asar; do
  [ -f "$asar" ] || continue
  grep -q "$marker" "$asar" && continue

  echo "$name: patching $asar"
  work=$(mktemp -d)
  npx --yes @electron/asar extract "$asar" "$work"

  perl -0pi -e 's/\Qapp.commandLine.appendSwitch("disable-features",disabledFeatures.join(","))\E/app.commandLine.appendSwitch("disable-features",[...disabledFeatures,"UseChromeOSDirectVideoDecoder"].join(","))/' "$work/bundle.js"
  perl -0pi -e 's/\Qelectron.app.commandLine.appendSwitch("enable-features","DocumentPolicyIncludeJSCallStacksInCrashReports")\E/electron.app.commandLine.appendSwitch("enable-features","DocumentPolicyIncludeJSCallStacksInCrashReports,VaapiOnNvidiaGPUs,VaapiIgnoreDriverChecks,PlatformHEVCDecoderSupport,AcceleratedVideoDecodeLinuxGL")/' "$work/bundle.js"

  if ! grep -q 'UseChromeOSDirectVideoDecoder' "$work/bundle.js" || ! grep -q "$marker" "$work/bundle.js"; then
    echo "$name: patterns not found, leaving $asar untouched" >&2
    command -v notify-send >/dev/null && notify-send "Discord patch failed" "Discord's code changed, update $name"
    rm -rf "$work"
    continue
  fi

  [ -f "$asar.bak" ] || cp "$asar" "$asar.bak"
  npx --yes @electron/asar pack "$work" "$asar"
  rm -rf "$work"
done
