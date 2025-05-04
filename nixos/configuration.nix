{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules
    ];

  networking.hostName = "mathai";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Asia/Kolkata";

  services.xserver.enable = true;
  services.fwupd.enable = true;
  services.printing.enable = true;
  networking.firewall.enable = true;
  services.libinput.enable = true;

  sops.secrets.mathai-password.neededForUsers = true;
  users.mutableUsers = false;

  users.users.mathai = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.mathai-password.path;
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    packages = with pkgs; [
      firefox
    ];
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.trusted-users = [ "root" "@wheel" ];

  # Allow unpackaged binaries to run
  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld-rs;

  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    gparted
  ];
  
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  environment.variables.EDITOR = "nvim";
  
  environment.sessionVariables = {
  EDITOR = "nvim";
  BROWSER = "firefox";
  TERMINAL = "kitty";
};

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.dates = "weekly";
    clean.extraArgs = "--keep-since 7d --keep 10";
    flake = "/home/mathai/.dotfiles";
  };

  nix.optimise.automatic = true;

  system.autoUpgrade = {
    enable = true;
    dates = "04:00";
    flake = "${config.users.users.mathai.home}/.dotfiles";
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
    ];
    allowReboot = true;
  };

  system.stateVersion = "24.05";

}
