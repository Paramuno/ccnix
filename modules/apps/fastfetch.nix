{ config, lib, pkgs, ... }:
{
  options.myModules.apps.fastfetch.enable = lib.mkEnableOption "fastfetch";
  config = lib.mkIf config.myModules.apps.fastfetch.enable {
    home.packages = [ pkgs.fastfetch ];
    xdg.configFile."fastfetch/config.jsonc".source = ../../static/fastfetch/config.jsonc;
  };
}
