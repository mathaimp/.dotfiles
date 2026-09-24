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
        self.homeModules.pi
      ];

      home.packages = with pkgs; [
        caligula
        nvitop
        gh

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
