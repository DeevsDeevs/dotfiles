#!/bin/zsh

set -e

if [[ "$OSTYPE" != darwin* ]]; then
    echo "Tinycast is macOS-only; nothing to install."
    exit 0
fi

if ! command -v brew >/dev/null; then
    echo "Homebrew is required: https://brew.sh" >&2
    exit 1
fi

macos_major="$(sw_vers -productVersion)"
macos_major="${macos_major%%.*}"

if (( macos_major >= 26 )); then
    if [[ "$(uname -m)" == "arm64" ]]; then
        cask="tinycast"
    else
        cask="tinycast-universal"
    fi
elif (( macos_major == 15 )); then
    cask="tinycast-sequoia"
else
    echo "Tinycast requires macOS 15 or newer." >&2
    exit 1
fi

brew trust --tap abue-ammar/tinycast
brew tap abue-ammar/tinycast

if brew list --cask "$cask" >/dev/null 2>&1; then
    echo "$cask is already installed."
else
    brew install --cask "$cask"
fi
