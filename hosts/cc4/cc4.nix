# ~/.config/home-manager/hosts/nixos.nix
{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/shared.nix
  ];
  home.stateVersion = "25.05";

  # Packages only on this host
  home.packages = with pkgs; [
    obsidian # Md notes
    proton-vpn # VPN paid
    proton-vpn-cli # For auto starting
  ];
  myModules.apps = {
    yazi.portal.enable = true; # NixOS yazi portal picker
    flatpak.enable = true;
    pureref.enable = true;
    supercollider.enable = true;
    t3code.enable = true;
    pi.enable = true; # Configured to use gemma4
    zotero.enable = true;
  };

  home.sessionVariables = {
    # Specify NVIDIA as the backend for various libraries
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland"; # Force Wayland for various toolkits
    XDG_CURRENT_DESKTOP = "hyprland"; # Portal variables
  };

  wayland.windowManager.hyprland = {
    enable = true;

    extraConfig = ''
      # exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland
      exec-once = dbus-update-activation-environment --systemd --all

      source = ~/.config/hypr/sources.conf

      input {
          sensitivity = -1.0
      }
    '';
  };

  # Per host extra configurations
  programs = {
    zsh.envExtra = ''
      export STARSHIP_HOST_ICON="*󰲠 "
    '';
    zsh.shellAliases = {
      # Rebuild the system flake
      ns = "cd ~/.config/home-manager && git add -A && sudo nixos-rebuild switch --flake .#cc4 && cd -";
      nd = "zellij delete-session 'cc1' --force";
    };
  };

}
