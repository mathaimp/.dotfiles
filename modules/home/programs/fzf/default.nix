{ options
, config
, lib
, pkgs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.fzf;

  stylixEnabled = config.${namespace}.programs.stylix.enable or false;

  accent = if stylixEnabled then "#" + config.lib.stylix.colors.base0D else null;
  foreground = if stylixEnabled then "#" + config.lib.stylix.colors.base05 else null;
  muted = if stylixEnabled then "#" + config.lib.stylix.colors.base03 else null;
in
{
  options.${namespace}.programs.fzf = with types; {
    enable = mkBoolOpt false "Enable programs.fzf";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      zsh-fzf-tab
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      colors = mkIf stylixEnabled (lib.mkForce {
        "fg+" = accent;
        "bg+" = "-1";
        "fg" = foreground;
        "bg" = "-1";
        "prompt" = muted;
        "pointer" = accent;
        });
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
      fileWidgetOptions = [
        "--walker-skip .git,node_modules,target"
        "--preview 'bat -n --color=always {}'"
        "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
      ];
      changeDirWidgetOptions = [
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
