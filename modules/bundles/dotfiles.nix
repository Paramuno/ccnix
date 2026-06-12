{ config, ... }:
{
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  home.file.".scripts" = {
    source = ../../static/scripts;
    recursive = true;
    executable = true;
  };

  home.file.".local/share/fonts" = {
    source = ../../static/fonts;
    recursive = true;
  };

  xdg.configFile = {
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/static/nvim";
    "user-dirs.dirs".source = ../../static/user-dirs.dirs;
    "mimeapps.list".source = ../../static/mimeapps.list;
    "browser".source = ../../static/browser; # browser dotfiles

    "fd/ignore".text = ''
      .local/share/Trash/
      .git/
      backups/
      vault/
      mnt/
    '';
  };
}
