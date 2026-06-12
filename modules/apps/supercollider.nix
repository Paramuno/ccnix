{ config, lib, ... }:
{
  options.myModules.apps.supercollider.enable = lib.mkEnableOption "supercollider";
  config = lib.mkIf config.myModules.apps.supercollider.enable {
    xdg.configFile."SuperCollider".source = ../../static/SuperCollider;
  };
}
