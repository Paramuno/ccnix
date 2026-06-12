{ config, lib, pkgs, ... }:
{
  options.myModules.apps.zsh.enable = lib.mkEnableOption "zsh";
  config = lib.mkIf config.myModules.apps.zsh.enable {
    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";

      oh-my-zsh = {
        enable = true;
        plugins = [
          "fasd"
        ];
        theme = "";
      };

      syntaxHighlighting.enable = true;

      initContent = ''
        # 1. Force load Home Manager session variables to bypass Wayland drops
        if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi

        source "$HOME/.config/shell/init.zsh"

        # Load zsh-autocomplete LAST to ensure it hooks everything correctly
        source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

        # Reclaim <C-s> from autocomplete
        bindkey '^S' fzf-history-widget

        # Reclaim these fasd bindings, this removes the Alt-l closing shell bug
        bindkey -r '^[l' '^[j' '^[k' '^[h'
      '';
      envExtra = ''
        # This ensures the Nix profile is available for SSH / non-interactive commands
        if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi
      '';
    };

    # nix config > .zshenv > .zshrc > shell/init.zsh > modules.zsh
    xdg.configFile."shell".source = ../../static/shell;
  };
}
