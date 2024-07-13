{ pkgs, ... }:
{
    stylix.targets.tmux.enable = false;
    programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.yank
      {
        plugin = tmuxPlugins.rose-pine;
        extraConfig = ''
        set -g @rose_pine_variant 'main'

        set -g @rose_pine_bar_bg_disable 'on'
        set -g @rose_pine_bar_bg_disabled_color_option 'default'

        set -g @rose_pine_host 'on'
        set -g @rose_pine_directory 'on'
        set -g @rose_pine_date_time '%H:%M'
        set -g @rose_pine_hostname_icon '|'
        set -g @rose_pine_date_time_icon '|'
        set -g @rose_pine_left_separator ' ' 
        set -g @rose_pine_right_separator ' '
        set -g @rose_pine_field_separator ' ' 
        set -g @rose_pine_window_separator ' '
        '';
      }
    ];
    extraConfig = ''
      set-option -sa terminal-overrides ",xterm*:Tc"

      set -g mouse on

      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      bind -n M-H previous-window
      bind -n M-L next-window 
    '';
  };
}
