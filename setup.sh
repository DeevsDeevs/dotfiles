#!/usr/bin/env bash

set -e  # exit if any command fails
set -u  # exit if trying to use unset variables

echo "🔧 Setting up your machine..."

# Helper functions
install_if_missing() {
  if ! command -v "$1" &> /dev/null; then
    echo "Installing $1..."
    if [[ "$OS" == "macos" ]]; then
      brew install "$2"
    elif [[ "$OS" == "linux" ]]; then
      sudo apt-get install -y "$2"
    fi
  else
    echo "$1 already installed ✔️"
  fi
}

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

# On macOS, ensure brew is installed
if [[ "$OS" == "macos" ]]; then
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# Update package managers
if [[ "$OS" == "linux" ]]; then
  sudo apt-get update
elif [[ "$OS" == "macos" ]]; then
  brew update
fi

# Install packages
install_if_missing stow stow
install_if_missing fzf fzf
install_if_missing bat bat
install_if_missing vivid vivid
install_if_missing zoxide zoxide
install_if_missing starship starship
install_if_missing tmux tmux
install_if_missing git git
install_if_missing nvim neovim

# Set up tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo "tmux plugin manager already installed ✔️"
fi

# Stow dotfiles
echo "Stowing dotfiles..."
stow zshrc
stow nvim
stow starship
stow tmux

echo "✅ Setup complete!"

