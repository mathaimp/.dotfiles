{
  nixpkgs,
  home-manager,
  inputs,
}:

let
  inherit (nixpkgs) lib;
  hostsDir = ../systems;

  homes = import ./mkHomes.nix {
    inherit (nixpkgs) lib;
  };

  mkHost =
    system: hostname:
    let
      matchingHomes = builtins.filter (h: h.system == system && h.hostname == hostname) homes;

      hmUsers = builtins.listToAttrs (
        map (h: {
          name = h.username;
          value = import h.path;
        }) matchingHomes
      );
    in
    lib.nixosSystem {
      inherit system;

      modules =
        builtins.attrValues inputs.self.nixosModules
        ++ inputs.self.nixosInputs
        ++ [
          {
            nixpkgs.config.allowUnfree = true;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              sharedModules = builtins.attrValues inputs.self.homeModules ++ inputs.self.homeInputs;
              extraSpecialArgs = {
                libEx = inputs.self.lib;
                inherit inputs;
                inherit (inputs.self) namespace;
              };

              users = hmUsers;
            };
          }

          home-manager.nixosModules.home-manager
          (hostsDir + "/${system}/${hostname}/default.nix")
        ];

      specialArgs = {
        inherit inputs;
        inherit (inputs.self) lib namespace;
      };
    };

  # discover hosts (unchanged)
  systems = builtins.attrNames (builtins.readDir hostsDir);

  hostsForSystem = system: builtins.attrNames (builtins.readDir (hostsDir + "/${system}"));

in
builtins.listToAttrs (
  builtins.concatMap (
    system:
    map (hostname: {
      name = hostname;
      value = mkHost system hostname;
    }) (hostsForSystem system)
  ) systems
)
