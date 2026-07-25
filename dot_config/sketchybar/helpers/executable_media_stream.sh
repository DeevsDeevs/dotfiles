#!/usr/bin/env bash

# Streams now-playing changes into the custom sketchybar event "media_change".
# Replaces the old 2s `media-control get` polling through sbar.exec, which
# pushed ~300KB of base64 artwork through the lua<->sketchybar Mach bridge on
# every tick and was implicated in deadlocks. Artwork is decoded here and
# passed to lua as a file path only.

set -u
export PATH="/usr/bin:/bin:/opt/homebrew/bin:$PATH"

# TMPDIR is per-user (0700) on macOS — no world-writable /tmp symlink games.
readonly ART_DIR="${TMPDIR:-$HOME/.cache}"
readonly ART="${ART_DIR%/}/sketchybar_album_art.jpg"

media-control stream 2>/dev/null | while IFS= read -r line; do
  payload="$(jq -c 'select(.type == "data") | .payload // {}' <<<"$line" 2>/dev/null)" || continue
  [[ -z "$payload" ]] && continue

  if [[ "$(jq -r '.diff // false' <<<"$line")" == "true" ]]; then
    state="$(jq -c --argjson patch "$payload" '. * $patch' <<<"${state:-{\}}")"
  else
    state="$payload"
  fi

  art="$(jq -r '.artworkData // empty' <<<"$payload")"
  if [[ -n "$art" ]]; then
    printf '%s' "$art" | base64 -d >"$ART.tmp" 2>/dev/null && mv -f "$ART.tmp" "$ART"
  fi

  sig="$(jq -r '[.playing, .title, .artist, .bundleIdentifier] | @tsv' <<<"$state")"
  if [[ "$sig" != "${last_sig:-}" || -n "$art" ]]; then
    last_sig="$sig"
    sketchybar --trigger media_change \
      PLAYING="$(jq -r '.playing // false' <<<"$state")" \
      TITLE="$(jq -r '.title // ""' <<<"$state")" \
      ARTIST="$(jq -r '.artist // ""' <<<"$state")" \
      APP="$(jq -r '.bundleIdentifier // ""' <<<"$state")" \
      ART_PATH="$ART"
  fi
done
