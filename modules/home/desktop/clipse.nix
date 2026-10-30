{
  # Clipboard history daemon; the compositor binds open the clipse TUI in a floating terminal
  # (history is plaintext, so keep passwords in Bitwarden). Shared by every compositor.
  flake.homeModules.clipse = {
    services.clipse = {
      enable = true;
      # Ghostty and kitty speak the kitty graphics protocol; the default "basic" mode shows nothing useful there.
      settings.imageDisplay = {
        type = "kitty";
        scaleX = 9;
        scaleY = 9;
        heightCut = 2;
      };
    };
  };
}
