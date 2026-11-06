{
  flake.homeModules.tmux =
    {
      pkgs,
      lib,
      ...
    }:
    let
      tmux = "${pkgs.tmux}/bin/tmux";
      # tmux-state <running|done|error|waiting|""> sets the window's @state.
      # done/error are dropped when you're already looking at the window.
      tmuxState = pkgs.writeShellScriptBin "tmux-state" ''
        [ -n "$TMUX_PANE" ] || exit 0
        state="$1"
        case "$state" in
          done|error)
            seen=$(${tmux} display -p -t "$TMUX_PANE" '#{&&:#{window_active},#{session_attached}}')
            [ "$seen" = 1 ] && state=""
            ;;
        esac
        if [ -n "$state" ]; then
          ${tmux} set-option -wq -t "$TMUX_PANE" @state "$state"
        else
          ${tmux} set-option -wuq -t "$TMUX_PANE" @state
        fi
        # "ping": ring the terminal bell (Ghostty plays a soft sound, works over ssh)
        if [ "$2" = ping ]; then
          tty=$(${tmux} display -p -t "$TMUX_PANE" '#{pane_tty}')
          printf '\a' > "$tty"
        fi
      '';
      # tmux-git <dir>: git status in the same format as the powerlevel10k prompt
      # (branch ⇣behind⇡ahead *stash ~conflicts +staged !unstaged ?untracked); empty outside a repo.
      tmuxGit = pkgs.writeShellScriptBin "tmux-git" ''
        out=$(${pkgs.git}/bin/git -C "$1" status --porcelain=v2 --branch --show-stash 2>/dev/null) || exit 0
        printf '%s\n' "$out" | awk '
          /^# branch.oid/ {oid=substr($3,1,8)}
          /^# branch.head/ {b=$3}
          /^# branch.upstream/ {up=$3; sub(/^[^\/]*\//,"",up)}
          /^# branch.ab/ {a=substr($3,2); d=substr($4,2)}
          /^# stash/ {st=$3}
          $1=="1" || $1=="2" { if (substr($2,1,1)!=".") s++; if (substr($2,2,1)!=".") m++ }
          $1=="u" {c++}
          $1=="?" {u++}
          END {
            G="#[fg=green]"; Y="#[fg=yellow]"; B="#[fg=blue]"; R="#[fg=red]"
            if (b=="(detached)") r="#[default]@" G oid
            else {
              if (length(b)>32) b=substr(b,1,12) "…" substr(b,length(b)-11)
              r=G b
              if (up!="" && up!=b) r=r "#[default]:" G up
            }
            if (d>0) r=r " " G "⇣" d
            if (a>0) r=r (d>0 ? "" : " ") G "⇡" a
            if (st>0) r=r " " G "*" st
            if (c>0) r=r " " R "~" c
            if (s>0) r=r " " Y "+" s
            if (m>0) r=r " " Y "!" m
            if (u>0) r=r " " B "?" u
            printf "#[fg=brightblack] | %s", r
          }'
      '';
    in
    {
      home.packages = [
        tmuxState
        tmuxGit
      ];
      programs.zsh.initContent = lib.mkAfter (builtins.readFile ./tmux-state.zsh);
      programs.tmux = {
        enable = true;
        mouse = true;
        keyMode = "vi";
        prefix = "C-Space";
        baseIndex = 1;
        sensibleOnTop = false;
        plugins = with pkgs; [
          tmuxPlugins.vim-tmux-navigator
          tmuxPlugins.yank
        ];
        extraConfig = ''
          set-option -ga terminal-overrides ",xterm*:Tc"

          # --- Sensible defaults (replaces tmuxplugin-sensible) ---
          set -g display-time 4000
          set -g status-interval 5
          bind C-p previous-window
          bind C-n next-window
          bind R source-file ~/.config/tmux/tmux.conf \; display-message "Sourced ~/.config/tmux/tmux.conf!"

          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
          bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

          bind '"' split-window -v -c "#{pane_current_path}"
          bind % split-window -h -c "#{pane_current_path}"

          bind Enter split-window -h -c "#{pane_current_path}"

          bind -n M-H previous-window
          bind -n M-L next-window

          set-option -g allow-passthrough on

          # --- Status Bar General ---
          set -g status "on"
          set -g status-style "fg=white,bg=default"
          set -g status-left-length "200"
          set -g status-right-length "200"

          # --- Windows Status Styling ---
          setw -g window-status-style "fg=magenta,bg=default"
          setw -g window-status-current-style "fg=blue,bold,bg=default"
          setw -g window-status-separator "#[fg=blue]  "

          # --- Activity state (@state set by tmux-state: running/done/error/waiting) ---
          set -g focus-events on
          set -g bell-action any
          set -g visual-bell off
          setw -g window-status-bell-style none
          set-hook -g after-select-window 'if -F "#{||:#{==:#{@state},done},#{==:#{@state},error}}" "set -wu @state"'
          set-hook -g client-session-changed 'if -F "#{||:#{==:#{@state},done},#{==:#{@state},error}}" "set -wu @state"'
          setw -g window-status-format "#{?#{==:#{@state},running},#[fg=white]● ,#{?#{==:#{@state},done},#[fg=green]○ ,#{?#{==:#{@state},error},#[fg=red]● ,#{?#{==:#{@state},waiting},#[fg=yellow]● ,}}}}#[fg=magenta]#I:#W#{?window_flags,#{window_flags}, }"
          setw -g window-status-current-format "#{?#{==:#{@state},running},#[fg=white]● ,#{?#{==:#{@state},done},#[fg=green]○ ,#{?#{==:#{@state},error},#[fg=red]● ,#{?#{==:#{@state},waiting},#[fg=yellow]● ,}}}}#[fg=blue,bold]#I:#W#{?window_flags,#{window_flags}, }"

          # --- Left Side: Session & Current Window ---
          # Shows: [Session Icon] SessionName [Window Icon] WindowName
          set -g status-left "#[fg=white] #[fg=white]#S  "

          # --- Right Side: User, Host, Time, Folder ---
          # Shows: User | Host | Time | Folder
          set -g status-right "#[fg=white]#(whoami)@#H#[fg=brightblack] | #[fg=brightblack] #[fg=green]#{b:pane_current_path}#(tmux-git '#{pane_current_path}')"

          # --- Pane & Message Styling ---
          set -g pane-border-style "fg=brightblack"
          set -g pane-active-border-style "fg=brightblack"
          set -g message-style "fg=brightblack,bg=default"
        '';
      };
    };
}
