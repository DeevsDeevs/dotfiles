#!/usr/bin/env bash

set -e
set -u

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

# Ensure Homebrew is installed (both macOS and Linux)
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # On Linux, set brew in the environment
  if [[ "$OS" == "linux" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" || eval "$(/root/.linuxbrew/bin/brew shellenv)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
    echo 'eval "$(/root/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
  fi
fi

# Ensure brew is in PATH (even if brew was just installed)
if [[ "$OS" == "linux" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
  eval "$(/root/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
fi

# Update package managers
if [[ "$OS" == "linux" ]]; then
  sudo apt-get update
elif [[ "$OS" == "macos" ]]; then
  brew update
fi

# Install packages
install_if_missing stow stow

# Install fzf always via brew
if ! command -v fzf &> /dev/null; then
  echo "Installing fzf with Homebrew..."
  brew install fzf
else
  echo "fzf already installed ✔️"
fi

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

