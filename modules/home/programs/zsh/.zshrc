# Turn of bell
unsetopt BEEP

# Keybindings
bindkey -v
bindkey "${terminfo[kcuu1]}" history-search-backward
bindkey "${terminfo[kcud1]}" history-search-forward
#bindkey 'v' history-search-backward

# History
HISTSIZE=100000
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
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# Better SSH/Rsync/SCP Autocomplete
zstyle ':completion:*:*:(ssh|scp|rsync):*:*' known-hosts-files ~/.ssh/known_hosts ~/.ssh/config

# Aliases
alias ls='eza'
alias la='eza -a'
alias c='clear'
alias e='exit'
alias update='nix flake update --flake ~/.dotfiles'
alias rebuild='nh os switch ~/.dotfiles/'
alias clean='nh clean all --keep=5'
alias rm='trash'

# Shell integrations
eval "$(fzf --zsh)"

# Remove Logging for direnv
export DIRENV_LOG_FORMAT=""
