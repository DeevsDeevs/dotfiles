#!/usr/bin/env sh

# Run sketchybar triggers from yabai with a hard timeout. If sketchybar hangs,
# yabai must not accumulate blocked `sketchybar --trigger ...` processes.
TIMEOUT_BIN=""
for candidate in \
  "$HOME/.local/share/devbox/global/default/.devbox/nix/profile/default/bin/timeout" \
  timeout \
  gtimeout
 do
  if command -v "$candidate" >/dev/null 2>&1; then
    TIMEOUT_BIN="$candidate"
    break
  fi
done

if [ -n "$TIMEOUT_BIN" ]; then
  "$TIMEOUT_BIN" 1s sketchybar --trigger "$@" >/dev/null 2>&1 || exit 0
else
  sketchybar --trigger "$@" >/dev/null 2>&1 &
fi
