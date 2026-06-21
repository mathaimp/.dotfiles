{ self, ... }:
{
  flake.homeModules.development-bundle =
    { pkgs
    , ...
    }:
    {
      imports = [
        self.homeModules.atuin
        self.homeModules.direnv
      ];

      home.packages = with pkgs; [
        caligula
        nvitop
        planify
        gh

        gemini-cli
        codex
        opencode

        # python
        uv

        # Notes
        obsidian
        zotero

        # robotics
        arduino-cli
        minicom
      ];

    };
}
