{ config, lib, pkgs, ... }:
{
  options.myModules.apps.fzf.enable = lib.mkEnableOption "fzf";
  config = lib.mkIf config.myModules.apps.fzf.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;

      # using fasd for file frequency ranking on results
      defaultCommand = "(fasd -Rfl 2>/dev/null; fd --type f --hidden) | awk 'seen[$ 0]++ == 0'";
      fileWidgetCommand = "(fasd -Rfl 2>/dev/null; fd --type f --hidden) | awk 'seen[$ 0]++ == 0'";

      changeDirWidgetCommand = "fd --type d --hidden";

      colors = {
        "bg+" = "#363a4f";
        "bg" = "-1";
        "info" = "#a6e3a1";
        "pointer" = "#ff4852";
        "preview-bg" = "#2c2e34";
        "prompt" = "#c6a0f6";
      };

      defaultOptions = [
        "--bind=ctrl-j:down,ctrl-k:up"
        "--bind=ctrl-d:half-page-down,ctrl-u:half-page-up"
        "--bind=alt-j:preview-half-page-down,alt-k:preview-half-page-up"
        "--layout=reverse"
        "--no-height"
        "--margin=1,2"
        "--tiebreak=index" # Force fzf to follow fasd ordering first
      ];
      fileWidgetOptions = [
        "--preview 'bat --color=always --style=plain {} 2>/dev/null'"
        "--preview-window=right:60%:border-left"
        "--height=80%"
        "--tiebreak=index" # Force fzf to follow fasd ordering first
      ];
    };
  };
}
