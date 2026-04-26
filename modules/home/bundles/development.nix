{ self, ... }:
{
  flake.homeModules.development-bundle =
    { pkgs
    , ...
    }:
    {
      imports = [
        self.homeModules.direnv
      ];

      home.packages = with pkgs; [
        caligula
        nvitop
        planify

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
