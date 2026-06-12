{ config, lib, pkgs, ... }:
{
  options.myModules.apps.dunst.enable = lib.mkEnableOption "dunst";
  config = lib.mkIf config.myModules.apps.dunst.enable {
    home.packages = [ pkgs.dunst ];
    xdg.configFile."dunst".source = ../../static/dunst;
  };
}
