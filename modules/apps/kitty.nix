{ config, lib, ... }:
{
  options.myModules.apps.kitty.enable = lib.mkEnableOption "kitty";
  config = lib.mkIf config.myModules.apps.kitty.enable {
    xdg.configFile."kitty".source = ../../static/kitty;
  };
}
