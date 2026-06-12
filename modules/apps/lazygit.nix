{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.lazygit.enable = lib.mkEnableOption "lazygit";
  config = lib.mkIf config.myModules.apps.lazygit.enable {
    home.packages = [ pkgs.lazygit ];
    xdg.configFile."lazygit".source = ../../static/lazygit;
  };
}
