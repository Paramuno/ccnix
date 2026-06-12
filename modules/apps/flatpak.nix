{
  config,
  lib,
  isNixOS,
  ...
}:

{
  options.myModules.apps.flatpak.enable = lib.mkEnableOption "flatpak apps";

  config = lib.mkIf config.myModules.apps.flatpak.enable {

    services.flatpak = {
      enable = true;
      uninstallUnmanaged = true;

      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];

      packages = [
        "com.usebottles.bottles"
        "com.github.tchx84.Flatseal"
        "com.bambulab.BambuStudio"
        "org.freecad.FreeCAD"
      ];

      update.auto = {
        enable = true;
        onCalendar = "weekly"; # Prevents it from slowing down every single boot
      };
    };

    # If you ever need to alias a flatpak command to your shell, do it here.
    # programs.zsh.shellAliases = {
    #   freecad = "flatpak run org.freecad.FreeCAD";
    # };
  };
}
