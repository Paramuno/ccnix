{
  config,
  lib,
  pkgs,
  isNixOS,
  ...
}:

{
  options.myModules.apps.syncthing.enable = lib.mkEnableOption "syncthing";

  config = lib.mkIf config.myModules.apps.syncthing.enable {

    home.packages = [ pkgs.syncthing ];

    services.syncthing = lib.mkIf isNixOS {
      enable = true;
    };

    # Manually define a localized systemd service for Fedora to prevent degradation
    systemd.user.services.syncthing-fedora = lib.mkIf (!isNixOS) {
      Unit = {
        Description = "Syncthing - Open Source Continuous File Synchronization (Fedora Fallback)";
        Documentation = "man:syncthing(1)";
        After = [ "network.target" ];
      };
      Service = {
        # Explicitly point to the Nix-managed binary in the store
        ExecStart = "${pkgs.syncthing}/bin/syncthing serve --no-browser --no-restart";
        Restart = "on-failure";
        RestartSec = 5;
        # Syncthing's standard exit codes for graceful restarts
        SuccessExitStatus = [
          3
          4
        ];
        RestartForceExitStatus = [
          3
          4
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
