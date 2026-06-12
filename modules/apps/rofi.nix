{ config, lib, pkgs, ... }:
{
  options.myModules.apps.rofi.enable = lib.mkEnableOption "rofi";
  config = lib.mkIf config.myModules.apps.rofi.enable {
    # xdotool: legacy X11 script dependency for rofi
    home.packages = with pkgs; [ rofi xdotool ];
    xdg.configFile."rofi".source = ../../static/rofi;
  };
}
