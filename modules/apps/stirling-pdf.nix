{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps."stirling-pdf" = {
    enable = lib.mkEnableOption "stirling-pdf";
    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Stirling-PDF IP address bind";
    };
  };

  config = lib.mkIf config.myModules.apps."stirling-pdf".enable {
    home.packages = [ pkgs.stirling-pdf ];

    systemd.user.services.stirling-pdf = {
      Unit = {
        Description = "Stirling-PDF Local Web Service";
        After = [ "network.target" ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        # Ensure a dedicated folder exists for Stirling-PDF's state/configs
        StateDirectory = "stirling-pdf";
        # %S is the systemd specifier for the state directory base (~/.local/state)
        WorkingDirectory = "%S/stirling-pdf";

        ExecStart = "${pkgs.stirling-pdf}/bin/Stirling-PDF";

        # Stirling-PDF is a Spring Boot application, so we override
        # the default port and host using its expected environment variables
        Environment = [
          "SERVER_PORT=12120"
          "SERVER_HOST=${config.myModules.apps."stirling-pdf".host}"
          "SECURITY_ENABLE_LOGIN=false"
        ];

        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    xdg.desktopEntries = {
      stirling-pdf = {
        name = "Stirling PDF";
        genericName = "PDF Editor";
        comment = "Local web-based PDF manipulation tool";
        exec = "xdg-open http://${config.myModules.apps."stirling-pdf".host}:12120";
        icon = "pdf";
        terminal = false;
        categories = [
          "Office"
          "Utility"
        ];
        mimeType = [ "application/pdf" ];
      };
    };
  };
}
