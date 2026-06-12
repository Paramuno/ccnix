{ config, lib, ... }:
{
  options.myModules.apps.kanata.enable = lib.mkEnableOption "kanata";
  config = lib.mkIf config.myModules.apps.kanata.enable {
    xdg.configFile."kanata".source = ../../static/kanata;
  };
}
