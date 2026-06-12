{ config, lib, pkgs, ... }:
{
  options.myModules.apps.zathura.enable = lib.mkEnableOption "zathura";
  config = lib.mkIf config.myModules.apps.zathura.enable {
    home.packages = [ pkgs.zathura ];
    xdg.configFile."zathura".source = ../../static/zathura;
  };
}
