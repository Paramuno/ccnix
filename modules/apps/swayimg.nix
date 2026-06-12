{ config, lib, pkgs, ... }:
{
  options.myModules.apps.swayimg.enable = lib.mkEnableOption "swayimg";
  config = lib.mkIf config.myModules.apps.swayimg.enable {
    home.packages = [ pkgs.swayimg ];
    xdg.configFile."swayimg".source = ../../static/swayimg;
  };
}
