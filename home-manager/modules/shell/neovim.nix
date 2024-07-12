{ lib, pkgs, config, ... }:

let
  linker = lib.fileContents "${pkgs.binutils}/nix-support/dynamic-linker"; 
in
{
  stylix.targets.vim.enable = false;

  home.activation = {
    cloneNvim = lib.hm.dag.entryAfter ["writeBoundry"]
    ''
    $DRY_RUN_CMD [ ! -e ${config.xdg.configHome}/nvim ] && git clone git@github.com:mathewp88/nvim.git ${config.xdg.configHome}/nvim || true
    '';
  };

  programs.neovim = {
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    enable = true;
    #withRuby = true;
    withPython3 = true;
    withNodeJs = true;
    vimAlias = true;
    vimdiffAlias = true;
    viAlias = true;
    extraPackages = with pkgs; [
      python311
      rustc
      cargo
      xclip
      ripgrep
      bottom
      curl
      fd
      wget
    ];
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
}

