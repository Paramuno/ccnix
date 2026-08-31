{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.apps.labguide;
  resolve = n: lib.getAttrFromPath (lib.splitString "." n) pkgs;
  norm =
    e:
    if builtins.isString e then
      {
        name = e;
        action = null;
        icon = null;
      }
    else
      e;
  toEntry = e: {
    inherit (e) name icon;
    desc = (resolve e.name).meta.description or "";
    exec = "${cfg.terminal} -e sh -c ${
      lib.escapeShellArg (if e.action != null then e.action else e.name)
    }";
  };
in
{
  options.myModules.apps.labguide = {
    enable = lib.mkEnableOption "labguide desktop widget";
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "Terminal used to launch curated packages";
    };
    packages = lib.mkOption {
      default = [ ];
      type =
        with lib.types;
        listOf (
          either str (submodule {
            options = {
              name = lib.mkOption { type = str; };
              action = lib.mkOption {
                type = nullOr str;
                default = null;
              };
              icon = lib.mkOption {
                type = nullOr str;
                default = null;
              };
            };
          })
        );
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.programs.ags.enable;
        message = "labguide requires myModules.apps.ags.enable";
      }
    ];

    home.packages = [ pkgs.figlet ]; # banner pane renders the hostname at runtime

    xdg.configFile."labguide" = {
      source = ../../static/labguide;
      recursive = true;
    };
    xdg.configFile."labguide/packages.json".text = builtins.toJSON (
      map (e: toEntry (norm e)) cfg.packages
    );

    systemd.user.services.labguide = {
      Unit = {
        Description = "AGS desktop widget";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
        StartLimitIntervalSec = 60;
        StartLimitBurst = 5;
      };
      Service = {
        ExecStart = "${config.programs.ags.finalPackage}/bin/ags -b labguide -c %h/.config/labguide/config.js";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install.WantedBy = [
        "graphical-session.target"
        "hyprland-session.target"
      ];
    };
  };
}
