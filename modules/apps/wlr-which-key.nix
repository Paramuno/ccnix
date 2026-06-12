{ config, lib, ... }:
{
  options.myModules.apps."wlr-which-key".enable = lib.mkEnableOption "wlr-which-key";
  config = lib.mkIf config.myModules.apps."wlr-which-key".enable {
    xdg.configFile."wlr-which-key".source = ../../static/wlr-which-key;
  };
}
