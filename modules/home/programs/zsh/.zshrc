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
zstyle ':completion:*' list-separator ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' show-group none
zstyle ':fzf-tab:*' prefix ''

zstyle ':completion:*:(ssh|scp|ftp|sftp|rsync):*' hosts $hosts
zstyle ':completion:*:(ssh|scp|ftp|sftp|rsync):*' users $users
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Aliases
alias ls='eza'
alias la='eza -a'
alias cat='bat'
alias c='clear'
alias e='exit'
alias update='nix flake update --flake ~/.dotfiles'
alias rebuild='nh os switch ~/.dotfiles/'
alias clean='nh clean all --keep=5'
alias rm='trash'

# Remove Logging for direnv
export DIRENV_LOG_FORMAT=""
