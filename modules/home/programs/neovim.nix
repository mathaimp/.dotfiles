{
  flake.homeModules.neovim =
    { pkgs
    , lib
    , ...
    }:
    let
      linker = lib.fileContents "${pkgs.binutils}/nix-support/dynamic-linker";
    in
    {

      home = {
        activation = {
          unlinkNvimConfig = lib.hm.dag.entryBefore [ "checkFilesChanged" ] ''
            rm -rf ~/.config/nvim
          '';
          linkNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            rm -rf ~/.config/nvim
            ln -sfn ~/.dotfiles/nvim ~/.config/nvim
          '';
        };

        sessionVariables = {
          EDITOR = "nvim";
        };
      };

      programs.neovim = {
        package = pkgs.neovim-unwrapped;
        defaultEditor = true;
        enable = true;
        withRuby = false;
        withPython3 = false;
        withNodeJs = false;
        vimAlias = true;
        vimdiffAlias = true;
        viAlias = true;
        extraPackages = with pkgs; [
          rustc
          cargo
          python3
          ripgrep
          curl
          fd
          wget
          imagemagick
        ];
        # make mason and stuff work
        extraWrapperArgs = [
          "--suffix"
          "NIX_LD_LIBRARY_PATH"
          ":"
          "${lib.makeLibraryPath [
            pkgs.stdenv.cc.cc
            pkgs.zlib
          ]}"
          "--set"
          "NIX_LD"
          "${linker}"
        ];
      };
    };
}
