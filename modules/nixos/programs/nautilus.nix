{
  flake.nixosModules.nautilus =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # The terminal is chosen on the home-manager side (the terminal's module sets it).
      terminal = lib.attrByPath [
        "home-manager"
        "users"
        config.preferences.user.name
        "preferences"
        "terminal"
      ] null config;
    in
    {
      environment.systemPackages = with pkgs; [
        nautilus
      ];

      programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = lib.mkIf (terminal != null) terminal;
      };
    };
}
