{
  flake.homeModules.fzf =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      stylixEnabled = config.programs.stylix.enable or false;

      accent = if stylixEnabled then "#" + config.lib.stylix.colors.base0D else null;
      foreground = if stylixEnabled then "#" + config.lib.stylix.colors.base05 else null;
      muted = if stylixEnabled then "#" + config.lib.stylix.colors.base03 else null;
    in
    {
      home.packages = with pkgs; [
        zsh-fzf-tab
      ];

      programs.fzf = {
        enable = true;
        enableZshIntegration = false;
        historyWidget.zsh.command = ""; # Diable while uisng atuin
        colors = lib.mkIf stylixEnabled (
          lib.mkForce {
            "fg+" = accent;
            "bg+" = "-1";
            "fg" = foreground;
            "bg" = "-1";
            "prompt" = muted;
            "pointer" = accent;
          }
        );
        defaultOptions = [
          "--margin=1"
          "--layout=reverse"
          "--border=rounded"
          "--info='hidden'"
          "--header=''"
          "--prompt='/ '"
          "-i"
          "--no-bold"
        ];
        fileWidget.options = [
          "--walker-skip .git,node_modules,target"
          "--preview 'bat -n --color=always {}'"
          "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
        ];
        changeDirWidget.options = [
          "--walker-skip .git,node_modules,target"
          "--preview 'tree -C {}'"
        ];
      };

      programs.zsh = {
        initContent = lib.mkBefore ''
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        '';
      };
    };
}
