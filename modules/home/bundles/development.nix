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
        tomato-c

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
