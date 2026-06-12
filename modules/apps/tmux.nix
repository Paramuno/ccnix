{ config, lib, ... }:
{
  options.myModules.apps.tmux.enable = lib.mkEnableOption "tmux";
  config = lib.mkIf config.myModules.apps.tmux.enable {
    xdg.configFile."tmux".source = ../../static/tmux;
  };
}
