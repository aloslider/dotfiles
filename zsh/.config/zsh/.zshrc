# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Config
HISTFILE=~/.config/zsh/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt beep extendedglob notify
unsetopt autocd nomatch
bindkey -e

autoload -Uz compinit
compinit

# Exports
export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$HOME/.local/go/bin:$HOME/.dotnet/tools:$PATH"
export ZSH="$HOME/.config/zsh/.oh-my-zsh"
export ZDOTDIR="$HOME/.config/zsh"
export EDITOR="nvim"
export TERM="kitty"
export XDG_CONFIG_HOME="$HOME/.config"
export NVIM_APPNAME="nvim/benq"
export DOCKER_HOST=unix:///run/user/1000/docker.sock
export GOPATH="$HOME/.local/go"

# Aliases

# lazy
lg() {
  lazygit "$@"
}

ld() {
  lazydocker "$@"
}

# docker
dcu() {
	docker compose up -d
}

dcl() {
	docker compose logs -ft
}

dcd() {
	docker compose down
}

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

COMPLETION_WAITING_DOTS="true"

plugins=(
  extract
  fzf
  git
	ssh-agent
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-vi-mode
)

# Auto-suggest
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
autoload -U compinit && compinit

# Load OMZ
source $ZSH/oh-my-zsh.sh

# User configuration

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# Add identities
ssh-add ~/.ssh/* 2>/dev/null
