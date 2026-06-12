{
  config,
  pkgs,
  lib,
  ...
}:
{
  # ── GPU & Hardware ──────────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam/32-bit apps
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORMT_HINT = "wayland";
  };
  # ── Desktop & Display ──────────────────────────────────────────────
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.dconf.enable = true; # dconf (CRITICAL: The GTK portal cannot start without this)

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-termfilechooser
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
      common = {
        default = [ "gtk" ];
      };
    };
  };
}
