{ options
, config
, lib
, pkgs
, inputs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.tmux;
in
{
  options.${namespace}.programs.tmux = with types; {
    enable = mkBoolOpt false "Enable tmux";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      mouse = true;
      keyMode = "vi";
      prefix = "C-a";
      sensibleOnTop = true;
      plugins = with pkgs; [
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
            set -g @rose_pine_folder_icon ' '
          '';
        }
      ];
      extraConfig = ''
        set-option -sa terminal-overrides ",xterm*:Tc"

        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
      
        bind Enter split-window -h -c "#{pane_current_path}"

        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        bind -n M-H previous-window
        bind -n M-L next-window 
      '';
    };
  };
}
