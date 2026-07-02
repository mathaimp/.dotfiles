{
  flake.nixosModules.gdm = {
    environment = {
      sessionVariables.MUTTER_DEBUG_DISABLE_HW_CURSORS = "1";
    };
    services.displayManager.gdm = {
      enable = true;
    };
  };
}
