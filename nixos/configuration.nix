{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules
    ];

  networking.hostName = "mathai";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kolkata";

  services.xserver.enable = true;

  services.xserver.desktopManager.gnome.enable = true;
  
  services.printing.enable = true;

  services.libinput.enable = true;

  users.users.mathai = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    ];
  };

  nixpkgs.config.allowUnfree = true;

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
    cloudflare-warp
  ];

  systemd.packages = [ pkgs.cloudflare-warp ];
  systemd.targets.multi-user.wants = [ "warp-svc.service" ];

  environment.variables.EDITOR = "nvim";

  # Enable cron for async weather
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/2 * * * *    mathai    ${builtins.toString ./.}/modules/weather.sh"
    ];
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/mathai/.dotfiles";
  };

  system.stateVersion = "24.05";

}

