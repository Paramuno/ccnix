{ config, lib, pkgs, ... }:
{
  options.myModules.apps.vlc.enable = lib.mkEnableOption "vlc";
  config = lib.mkIf config.myModules.apps.vlc.enable {
    home.packages = [ pkgs.vlc ];
    xdg.configFile."vlc".source = ../../static/vlc;
  };
}
