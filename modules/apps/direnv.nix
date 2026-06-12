{ config, lib, pkgs, ... }:
{
  options.myModules.apps.direnv.enable = lib.mkEnableOption "direnv";
  config = lib.mkIf config.myModules.apps.direnv.enable {
    programs.direnv = {
      enable = true;

      enableZshIntegration = true;

      nix-direnv.enable = true;
    };
  };
}
