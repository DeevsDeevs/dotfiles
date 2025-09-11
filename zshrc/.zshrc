export LS_COLORS="$(vivid generate catppuccin-mocha)"

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${HOME}/.config/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Starship prompt
eval "$(starship init zsh)"

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

mkdir ~/.cache/zinit/completions > /dev/null 2>&1

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

# Shell integrations
if command -v fzf > /dev/null; then
  FZF_VERSION=$(fzf --version | awk '{print $1}')
  if [[ "$(printf '%s\n' 0.48.0 "$FZF_VERSION" | sort -V | head -n1)" == "0.48.0" ]]; then
    eval "$(fzf --zsh)"
  fi
fi

if [ -z "$DISABLE_ZOXIDE" ]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# Start ssh-agent if not running
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
fi

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS - use Apple Keychain
  ssh-add --apple-use-keychain ~/.ssh/github > /dev/null 2>&1
  ssh-add --apple-use-keychain ~/.ssh/id_rsa > /dev/null 2>&1
  ssh-add --apple-use-keychain ~/.ssh/deevs > /dev/null 2>&1
else
  # Linux - normal ssh-add
  ssh-add ~/.ssh/github > /dev/null 2>&1
  ssh-add ~/.ssh/id_rsa > /dev/null 2>&1
  ssh-add ~/.ssh/deevs > /dev/null 2>&1
fi

. "$HOME/.local/bin/env"
export PATH="$PATH:/opt/nvim/"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/deevs/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/deevs/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/deevs/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/deevs/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

export PATH=$PATH:/Users/deevs/.spicetify
