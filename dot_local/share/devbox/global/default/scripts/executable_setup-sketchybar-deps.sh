#!/bin/zsh

# Brew-only prerequisites for the bar. Everything the bar itself needs — the C
# helpers, SbarLua, the app font — is installed by its own install.sh, which
# lives in the deevs-sketchybar repo that chezmoi pulls in as an external.
# This script used to compile the helpers itself with a single `make` in
# helpers/, which stopped existing when the bar moved to its own repo: the
# makefiles are per-subdirectory now, and without `set -e` the failure printed
# "installed successfully" anyway.

set -e

if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

echo "Installing SketchyBar dependencies..."

brew install media-control
brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro

if [[ -x ~/.config/sketchybar/install.sh ]]; then
    echo "Running the bar's own installer (helpers, SbarLua, app font)..."
    ~/.config/sketchybar/install.sh
else
    echo "~/.config/sketchybar/install.sh not found — run 'chezmoi apply' first," >&2
    echo "which clones the bar, then re-run this script." >&2
    exit 1
fi

echo "SketchyBar dependencies installed successfully!"
