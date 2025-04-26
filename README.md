# Dotfiles

## What's Included

- **ZSH Configuration**: Custom `.zshrc` with useful aliases and functions
- **Neovim**: Modern text editor configuration
- **Tmux**: Terminal multiplexer setup with plugin manager
- **Starship**: Cross-shell prompt configuration
- **Ghostty**: Terminal emulator settings

## Dependencies

The setup script will install these tools if missing:

- stow (for symlink management)
- ripgrep, fzf, bat (CLI utilities)
- vivid (for LS_COLORS)
- zoxide (smarter cd)
- tmux
- starship
- neovim
- uv (Python package installer)

## Installation

1. Clone this repository:

```bash

git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Run the setup script:

```bash
./setup.sh
```

The script will:

- Detect your OS (macOS or Linux)
- Install missing dependencies (using Homebrew on macOS or apt on Linux)
- Stow configurations to your home directory
- Set up tmux plugin manager

## Manual Configuration

If you prefer not to use the setup script, you can manually stow individual configurations:

```bash
stow zshrc    # For ZSH configuration
stow nvim     # For Neovim configuration 
stow tmux     # For Tmux configuration
stow starship # For Starship prompt
stow ghostty  # For Ghostty terminal
```
