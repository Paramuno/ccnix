{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.waybar.enable = lib.mkEnableOption "waybar";
  config = lib.mkIf config.myModules.apps.waybar.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          position = "top";
          layer = "top";
          exclusive = false;
          height = 49;
          "margin-left" = 5;
          "margin-right" = 5;
          spacing = 4;

          include = [
            "~/.config/waybar/modules.json"
          ];

          modules-left = [
            "hyprland/window"
          ];

          modules-center = [
            "hyprland/workspaces"
          ];

          modules-right = [
            "mpd"
            "pulseaudio"
            "network"
            "tray"
            "custom/vault"
            "battery"
            "clock"
          ];
        };
      };
    };

    # Mix static modules.json and other files with the declarative config above
    xdg.configFile."waybar" = {
      source = ../../static/waybar;
      recursive = true;
    };
  };
}
