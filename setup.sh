#!/usr/bin/env bash

set -e  # Exit if any command fails
set -u  # Exit if trying to use unset variables

echo "🔧 Setting up your machine..."

# Helper function to install packages if missing
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

# On macOS, ensure Homebrew is installed
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
install_if_missing ripgrep ripgrep
install_if_missing fzf fzf
install_if_missing bat bat
install_if_missing vivid vivid
install_if_missing zoxide zoxide
install_if_missing starship starship
install_if_missing tmux tmux
install_if_missing git git

# Install Neovim
if ! command -v nvim &> /dev/null; then
  echo "Installing Neovim..."
  if [[ "$OS" == "linux" ]]; then
    # Download Neovim AppImage
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    chmod u+x nvim-linux-x86_64.appimage

    # Attempt to run the AppImage
    if ./nvim-linux-x86_64.appimage --version &> /dev/null; then
      echo "Neovim AppImage is executable."
      sudo mkdir -p /opt/nvim
      sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim
    else
      echo "AppImage execution failed. Attempting to extract..."
      ./nvim-linux-x86_64.appimage --appimage-extract
      sudo mv squashfs-root /opt/nvim
      sudo ln -s /opt/nvim/AppRun /usr/bin/nvim
    fi
  elif [[ "$OS" == "macos" ]]; then
    brew install neovim
  fi
else
  echo "Neovim already installed ✔️"
fi

# Install uv
if ! command -v uv &> /dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "uv already installed ✔️"
fi

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

# Reload the terminal session
echo "Reloading the terminal session..."
exec "$SHELL"

echo "✅ Setup complete!"

