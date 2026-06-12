{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.git.enable = lib.mkEnableOption "git";
  config = lib.mkIf config.myModules.apps.git.enable {
    home.packages = with pkgs; [
      diffnav
    ];
    programs.git = {
      enable = true;
      ignores = [ ".direnv/" ];
      settings = {
        user.name = "paramuno";
        user.email = "wooxgfx@gmail.com";
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "nvim";
        pager = {
          diff = "diffnav";
          show = "diffnav";
          log = "diffnav";
        };
        # url = {
        #   "git@github.com:" = {
        #     insteadOf = "https://github.com/";
        #   };
        # };
      };
      # delta.enable = true;
    };
  };
}
