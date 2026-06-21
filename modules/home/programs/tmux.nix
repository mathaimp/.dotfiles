{
  flake.homeModules.tmux =
    { pkgs
    , ...
    }:
    {
      programs.tmux = {
        enable = true;
        mouse = true;
        keyMode = "vi";
        prefix = "C-Space";
        baseIndex = 1;
        sensibleOnTop = true;
        plugins = with pkgs; [
          tmuxPlugins.vim-tmux-navigator
          tmuxPlugins.yank
        ];
        extraConfig = ''
          set-option -ga terminal-overrides ",xterm*:Tc"

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
          setw -g window-status-current-style "fg=yellow,bg=default"
          setw -g window-status-separator "#[fg=blue]  "

          # --- Left Side: Session & Current Window ---
          # Shows: [Session Icon] SessionName [Window Icon] WindowName
          set -g status-left "#[fg=white] #[fg=white]#S  "

          # --- Right Side: User, Host, Time, Folder ---
          # Shows: User | Host | Time | Folder
          set -g status-right "#[fg=white]#(whoami)#[fg=white]@#[fg=white]#H#[fg=brightblack] | #[fg=cyan]%H:%M#[fg=brightblack] | #[fg=brightblack] #[fg=green]#{b:pane_current_path}"

          # --- Pane & Message Styling ---
          set -g pane-border-style "fg=brightblack"
          set -g pane-active-border-style "fg=brightblack"
          set -g message-style "fg=brightblack,bg=default"
        '';
      };
    };
}
