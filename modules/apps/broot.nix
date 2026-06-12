{ config, lib, ... }:
{
  options.myModules.apps.broot.enable = lib.mkEnableOption "broot";
  config = lib.mkIf config.myModules.apps.broot.enable {
    programs.broot = {
      enable = true;

      # This is critical: it generates the `br` command allowing broot to change your shell directory
      # enableBashIntegration = true;
      # enableFishIntegration = true;
      enableZshIntegration = true;

      settings = {
        # Activates Normal/Insert modes
        modal = true;

        # Starts broot in Normal mode so h/j/k/l work the second you launch it
        initial_mode = "command";

      };
    };
  };
}
