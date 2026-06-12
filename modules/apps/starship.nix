{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.starship.enable = lib.mkEnableOption "starship";
  config = lib.mkIf config.myModules.apps.starship.enable {
    home.packages = [
      pkgs.starship
    ];
    xdg.configFile."starship".source = ../../static/starship;
  };
}
