#!/usr/bin/env sh
# Leaked yabai animation-proxy windows (frozen unclickable copies of app
# windows; yabai-owned at the CG level). Lists them; --fix restarts yabai.
# Proxies exist legitimately during a 0.35s animation, so only windows that
# survive a 1s recheck count as ghosts.
bin="${TMPDIR:-/tmp}/yabai_ghostcheck"
src="$(dirname "$0")/ghostcheck.c"
{ [ -x "$bin" ] && [ "$bin" -nt "$src" ]; } || clang -framework CoreGraphics -framework CoreFoundation -o "$bin" "$src" || exit 1
g1=$("$bin" | grep '^yabai|'); [ -z "$g1" ] && { echo "no ghosts"; exit 0; }
sleep 1
g2=$("$bin" | grep '^yabai|'); [ -z "$g2" ] && { echo "no ghosts (transient animation)"; exit 0; }
echo "$g2"
[ "$1" = "--fix" ] && yabai --restart-service && echo "yabai restarted, ghosts cleared"
