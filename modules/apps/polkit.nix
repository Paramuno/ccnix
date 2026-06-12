{
  config,
  lib,
  isNixOS,
  ...
}:

{
  options.myModules.apps.polkit.enable = lib.mkEnableOption "polkit authentication agent";

  config = lib.mkIf (config.myModules.apps.polkit.enable && isNixOS) {

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "Polkit GNOME Authentication Agent";
        After = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
        # CRITICAL: Only start this service if Hyprland is the active desktop.
        # This prevents collisions when you log into your fallback Plasma session.
        ConditionEnvironment = "XDG_CURRENT_DESKTOP=hyprland";
      };
      Service = {
        Type = "simple";
        # Execute the globally available system binary
        ExecStart = "/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
