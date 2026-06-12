{ config, lib, pkgs, ... }:
{
  options.myModules.apps.vifm.enable = lib.mkEnableOption "vifm";
  config = lib.mkIf config.myModules.apps.vifm.enable {
    home.packages = [ pkgs.vifm ];
    xdg.configFile."vifm".source = ../../static/vifm;
  };
}
