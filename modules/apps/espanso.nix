{
  config,
  lib,
  pkgs,
  isNixOS,
  ...
}:
{
  options.myModules.apps.espanso.enable = lib.mkEnableOption "espanso";

  config = lib.mkIf config.myModules.apps.espanso.enable {

    xdg.configFile."espanso".source = ../../static/espanso;

    # 2. Only install the Wayland package natively on NixOS
    #   home.packages = lib.mkIf isNixOS [ pkgs.espanso-wayland ];
    #
    #   # 3. Define the service manually to bypass Home Manager's file generation
    #   systemd.user.services.espanso = lib.mkIf isNixOS {
    #     Unit = {
    #       Description = "Espanso Daemon";
    #       After = [ "graphical-session.target" ];
    #     };
    #     Service = {
    #       ExecStart = "${pkgs.espanso-wayland}/bin/espanso daemon";
    #       Restart = "on-failure";
    #       RestartSec = 3;
    #     };
    #     Install = {
    #       WantedBy = [ "graphical-session.target" ];
    #     };
    #   };
  };

}
