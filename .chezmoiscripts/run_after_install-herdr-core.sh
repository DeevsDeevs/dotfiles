#!/bin/sh
# herdr-core has no Nix package (herdr-nix ships only the TUI), so use the
# official installer once; after that `hc update` and the app keep it current.
set -eu
[ -x "$HOME/.local/bin/herdr-core" ] && exit 0
curl -fsSL https://releases.herdr.dev/core/install.sh | sh
