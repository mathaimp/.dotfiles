{
  flake.nixosModules.vms =
    {
      pkgs,
      ...
    }:
    {
      # Set up virtualisation
      virtualisation.libvirtd = {
        enable = true;

        # Enable TPM emulation (for Windows 11)
        qemu = {
          swtpm.enable = true;
        };
      };

      # Enable USB redirection
      virtualisation.spiceUSBRedirection.enable = true;

      # Allow VM management
      users.groups.libvirtd.members = [ "mathai" ];
      users.groups.kvm.members = [ "mathai" ];

      environment.systemPackages = with pkgs; [
        gnome-boxes # VM management
        dnsmasq # VM networking
        phodav # (optional) Share files with guest VMs
      ];

    };
}
