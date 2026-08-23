#!/bin/sh
set -eu

command -v brew >/dev/null || { echo "Homebrew is required" >&2; exit 1; }
brew install --cask openlogi
