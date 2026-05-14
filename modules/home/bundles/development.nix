{ self, ... }:
{
  flake.homeModules.development-bundle =
    {
      pkgs,
      ...
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
        pi-coding-agent

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
