{ config, lib, pkgs, ... }:
# Requires mutable json structure
{
  options.myModules.apps.ags.enable = lib.mkEnableOption "ags";
  config = lib.mkIf config.myModules.apps.ags.enable {
    programs.ags = {
      enable = true;
      extraPackages = with pkgs; [
        gtksourceview
      ];
    };

    xdg.configFile."ags".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/static/ags";
  };
}
