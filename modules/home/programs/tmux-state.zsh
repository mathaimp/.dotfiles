# Report long-running commands to tmux (@state: running | done | error).
# Commands under $_tmux_state_min seconds never show anything.
if [[ -n $TMUX ]]; then

zmodload zsh/datetime
autoload -Uz add-zsh-hook

typeset -g _tmux_state_min=10
typeset -g _tmux_state_pid _tmux_state_start _tmux_state_track
# Interactive programs that are "running" the whole time they are open.
# claude reports its own state through hooks instead.
typeset -ga _tmux_state_ignore=(nvim vim vi nano less man bat htop btop top nvitop ssh claude opencode lazygit yazi fzf watch tmux)

_tmux_state_preexec() {
  local words=(${(z)1})
  # skip leading sudo/env-style prefixes
  while [[ ${words[1]} == (sudo|env|command|time|nohup|[A-Za-z_]*=*) ]]; do shift words; done
  if (( ${_tmux_state_ignore[(Ie)${words[1]:t}]} )); then
    _tmux_state_track=
    return
  fi
  _tmux_state_track=1
  _tmux_state_start=$EPOCHSECONDS
  ( sleep $_tmux_state_min && tmux-state running ) &!
  _tmux_state_pid=$!
}

_tmux_state_precmd() {
  local rc=$?
  [[ -n $_tmux_state_track ]] || return
  _tmux_state_track=
  kill $_tmux_state_pid 2>/dev/null
  (( EPOCHSECONDS - _tmux_state_start >= _tmux_state_min )) || return
  # 130 = Ctrl-C, not an error worth flagging
  if (( rc == 0 || rc == 130 )); then tmux-state done; else tmux-state error; fi
}

add-zsh-hook preexec _tmux_state_preexec
add-zsh-hook precmd _tmux_state_precmd
fi
