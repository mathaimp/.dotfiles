{ config
, pkgs
, lib
, namespace
, inputs
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.neovim;
  linker = lib.fileContents "${pkgs.binutils}/nix-support/dynamic-linker";
in
{
  options.${namespace}.programs.neovim = {
    enable = mkBoolOpt false "${namespace}.programs.neovim.enable";
  };
  config = mkIf cfg.enable {

    xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/nvim";

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.neovim = {
      package = pkgs.neovim-unwrapped;
      defaultEditor = true;
      enable = true;
      withRuby = true;
      withPython3 = true;
      withNodeJs = true;
      vimAlias = true;
      vimdiffAlias = true;
      viAlias = true;
      extraPackages = with pkgs; [
        python311
        devpod
        rustc
        cargo
        ripgrep
        curl
        fd
        wget
      ];
      # Ensure no init.lua is made
      extraConfig = "";
      extraLuaConfig = "";
      # make mason and stuff work
      extraWrapperArgs = [
        "--suffix"
        "NIX_LD_LIBRARY_PATH"
        ":"
        "${lib.makeLibraryPath [pkgs.stdenv.cc.cc pkgs.zlib]}"
        "--set"
        "NIX_LD"
        "${linker}"
      ];
    };
  };
}
