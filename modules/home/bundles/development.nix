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
        gh

        codex
        opencode
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
