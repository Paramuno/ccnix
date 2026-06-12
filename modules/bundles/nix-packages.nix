{
  lib,
  pkgs,
  isNixOS,
  ...
}:

lib.mkIf isNixOS {
  home.packages = with pkgs; [
    neovim # Raw nvim binary
    kitty # GPU accelerated so fedora has it on dnf
    psmisc # Adds killall service cmd, fuser, and pstree
    xdg-desktop-portal-gtk # Allows yazi as desktop portal
    xdg-desktop-portal-termfilechooser # Allows yazi as desktop portal
    # Dependencies
    tree-sitter # for nvim tree-sitter compilation
    nodejs # for nvim tree-sitter compilation
    gnumake # Compiler dependency
    libnotify # Adds notify-send cmd
    socat # Added for Hyprland IPC tracking, Bottles mod ags script fix
    nil # The Nix Language Server (nil_ls in Neovim)
    statix # The Nix linter complaining about ENOENT
    nixfmt # Highly recommended formatter for Nix
    hyprlock # To lock screen, it's installed on dnf in fedora
  ];

  # Dark theme for gnome
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
