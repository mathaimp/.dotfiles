{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nmap
    xorg.xhost
  ];            
}
