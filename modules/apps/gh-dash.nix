{ config, lib, ... }:
{
  options.myModules.apps.gh-dash.enable = lib.mkEnableOption "gh-dash";
  config = lib.mkIf config.myModules.apps."gh-dash".enable {
    programs.gh-dash = {
      enable = true;

      # settings = {
      #   prSections = [
      #     {
      #       title = "PR";
      #       filters = "is:open author:@me";
      #     }
      #     {
      #       title = "Review";
      #       filters = "is:open review-requested:@me";
      #     }
      #   ];
      #   issueSections = [
      #     {
      #       title = "Assigned Issues";
      #       filters = "is:open assignee:@me";
      #     }
      #   ];
      # };
    };

  };
}
