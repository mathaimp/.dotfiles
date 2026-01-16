{
  description = "Olympus NixOS flake";

  inputs = {
    # Nixpkgs from unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # For any hardware quirks
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Home manager unstable for home pkgs
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko for deterministic filesytems
    disko.url = "github:nix-community/disko";

    # Secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # For secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Repo for sops-nix
    nix-secrets = {
      url = "git+ssh://git@github.com/mathewp88/.nix-secrets?shallow=1&ref=main";
      flake = false;
    };

    # Auto Theming
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Spotify w/ modifications
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Apple font
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";

    # Yazi Plugins
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { flake-parts, nixpkgs, home-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [ "x86_64-linux" "aarch64-linux" ];

      flake = {

        namespace = "olympus";

        nixosInputs = with inputs; [
          lanzaboote.nixosModules.lanzaboote
          stylix.nixosModules.stylix
          sops-nix.nixosModules.sops
        ];

          homeInputs = with inputs; [
            sops-nix.homeManagerModules.sops
            spicetify-nix.homeManagerModules.default
          ];

        lib = import ./lib {
          nixpkgs = nixpkgs;
          namespace = inputs.self.namespace;
        };

        nixosConfigurations = 
          import ./lib/mkHosts.nix {
            inherit nixpkgs home-manager inputs;
          };

        nixosModules =
          import ./lib/mkNixosModules.nix {
            lib = nixpkgs.lib;
          };

        homeModules =
          import ./lib/mkHomeModules.nix {
            lib = nixpkgs.lib;
          };
      };
    };
}
