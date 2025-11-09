{
  description = "Olympus Nix Config";

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

    # Organizing Nix Conf
    snowfall-lib = {
      url = "github:snowfallorg/lib";
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

  };

  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;

        # Metadata
        snowfall = {
          namespace = "olympus";
          meta = {
            name = "olympus";
            title = "Olympus";
          };
        };
      };
    in
    lib.mkFlake {
      inherit inputs;
      src = ./.;

      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [ ];
      };

      overlays = with inputs; [ ];

      systems.modules.nixos = with inputs; [
        lanzaboote.nixosModules.lanzaboote
        sops-nix.nixosModules.sops
      ];

      homes.modules = with inputs; [
        sops-nix.homeManagerModules.sops
        spicetify-nix.homeManagerModules.default
      ];

      systems.hosts.ares.modules = with inputs; [
        # Same hardware as the victus
        nixos-hardware.nixosModules.omen-16-n0280nd
        stylix.nixosModules.stylix
      ];

      systems.hosts.hermes.modules = with inputs; [
        nixos-hardware.nixosModules.raspberry-pi-4
      ];

      templates = import ./templates { };
    };
}
