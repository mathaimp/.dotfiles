{ inputs, self, ... }:
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
        inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
        opencode

        # python
        uv

        # Notes
        obsidian
        inputs.nixpkgs-zotero.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zotero # pinned, see flake.nix

        # robotics
        arduino-cli
        minicom
      ];

    };
}
