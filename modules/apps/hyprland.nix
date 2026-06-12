{ config, lib, isNixOS, ... }:
{
  options.myModules.apps.hyprland.enable = lib.mkEnableOption "hyprland";
  config = lib.mkIf config.myModules.apps.hyprland.enable {
    xdg.configFile."hypr" = {
      source = ../../static/hypr;
      recursive = true;
    };

    xdg.configFile."hypr/sources.conf" = {
      source =
        if isNixOS then
          ../../static/hypr-choose/sources-nixos.conf
        else
          ../../static/hypr-choose/sources-fedora.conf;
    };
  };
}
