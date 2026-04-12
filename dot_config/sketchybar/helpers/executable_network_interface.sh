#!/usr/bin/env bash

set -u

detect_from_summary() {
  local iface summary
  for iface in $(ifconfig -l 2>/dev/null); do
    summary=$(ipconfig getsummary "$iface" 2>/dev/null || true)
    if [[ "$summary" == *" SSID : "* ]]; then
      printf '%s\n' "$iface"
      return 0
    fi
  done
  return 1
}

detect_from_system_profiler() {
  system_profiler SPAirPortDataType 2>/dev/null \
    | awk '/^[[:space:]]*en[0-9]+:$/ { gsub(":", "", $1); print $1; exit }'
}

detect_from_default_route() {
  route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}'
}

iface="$(detect_from_summary || true)"
if [[ -z "$iface" ]]; then
  iface="$(detect_from_system_profiler || true)"
fi
if [[ -z "$iface" ]]; then
  iface="$(detect_from_default_route || true)"
fi

printf '%s\n' "${iface:-en0}"
