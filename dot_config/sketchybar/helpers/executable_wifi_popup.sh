#!/usr/bin/env bash

set -u

readonly HOME_DIR="${HOME:-/Users/deevs}"
readonly CONFIG_DIR="${CONFIG_DIR:-$HOME_DIR/.config/sketchybar}"
readonly INTERFACE_SCRIPT="$CONFIG_DIR/helpers/network_interface.sh"
readonly BRACKET="widgets.wifi.bracket"
readonly SSID_ITEM="widgets.wifi.ssid"
readonly NETWORKS_ITEM="widgets.wifi.networks"
readonly LABEL_GREY="0xff7f8490"
readonly WIFI_SETTINGS_URL="x-apple.systempreferences:com.apple.Network-Settings.extension?Wi-Fi"

get_interface() {
  if [[ -x "$INTERFACE_SCRIPT" ]]; then
    "$INTERFACE_SCRIPT"
    return 0
  fi
  printf '%s\n' "en0"
}

current_ssid() {
  local iface="$1"
  local ssid=""

  ssid="$(networksetup -getairportnetwork "$iface" 2>/dev/null | sed -n 's/^Current Wi-Fi Network: //p' | head -n1)"
  if [[ -n "$ssid" ]]; then
    printf '%s\n' "$ssid"
    return 0
  fi

  ssid="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk -F ': ' '/ SSID/ {print $2; exit}')"
  if [[ -n "$ssid" ]]; then
    printf '%s\n' "$ssid"
    return 0
  fi

  ssid="$(ipconfig getsummary "$iface" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2; exit}')"
  if [[ -n "$ssid" ]]; then
    printf '%s\n' "$ssid"
    return 0
  fi

  printf '%s\n' "Wi-Fi"
}

ssid="$(current_ssid "$(get_interface)")"

sketchybar \
  --set "$SSID_ITEM" label.string="$ssid" \
  --set "$NETWORKS_ITEM" label.string="Open Wi-Fi" label.color="$LABEL_GREY" click_script="open '$WIFI_SETTINGS_URL'" \
  --set "$BRACKET" popup.drawing=toggle
