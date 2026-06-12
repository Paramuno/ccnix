# modules/apps/yazi.nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.yazi = {
    enable = lib.mkEnableOption "yazi";
    # Add a specific toggle for the portal integration
    portal.enable = lib.mkEnableOption "yazi desktop portal integration";
  };

  config = lib.mkMerge [
    # 1. Base Yazi configuration (Applies to both NixOS and Fedora)
    (lib.mkIf config.myModules.apps.yazi.enable {
      home.packages = with pkgs; [
        # pkgs.yazi
        (writeShellScriptBin "yazi" ''
          # export YAZI_LOG=debug
          exec ${pkgs.yazi}/bin/yazi "$@"
        '')
      ];
      xdg.configFile."yazi".source = ../../static/yazi;
    })

    # 2. Portal-specific configuration (Applies ONLY when portal.enable is true)
    (lib.mkIf config.myModules.apps.yazi.portal.enable {
      xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
        [filechooser]
        cmd=${config.home.homeDirectory}/.local/bin/yazi-picker.sh
        default_dir=${config.home.homeDirectory}/Downloads
      '';

      home.file.".local/bin/yazi-picker.sh" = {
        executable = true;
        text = /* bash */ ''
            #!/usr/bin/env bash

            if [ "''${6:-0}" -ge 4 ]; then set -x; fi

            LOG="/tmp/yazi-portal.log"
            KITTY="${pkgs.kitty}/bin/kitty"
            YAZI="${pkgs.yazi}/bin/yazi"

            multiple="$1"
            directory="$2"
            save="$3"
            path="''${4:-$HOME}"
            out="$5"

           # 1. Build the Yazi arguments based on the portal request type
            if [ "$save" = "1" ]; then
                set -- --chooser-file="$out" "$path"
            elif [ "$directory" = "1" ]; then
              # Use the example's two-file strategy for better directory support
                set -- --chooser-file="$out" --cwd-file="$out.dir" "$path"
            else
                set -- --chooser-file="$out" "$path"
            fi

          # 2. Build the command string with robust escaping
          # We keep your essential -u DBUS_SESSION_BUS_ADDRESS fix here
            command="env -u DBUS_SESSION_BUS_ADDRESS $KITTY --class yazi-picker -o linux_display_server=wayland -- $YAZI"
            for arg in "$@"; do
                escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
                command="$command \"$escaped\""
            done

          # 3. Execute and handle directory fallback
            sh -c "$command" >> "$LOG" 2>&1

            if [ "$directory" = "1" ]; then
              # If no file was chosen but a directory was reached, use the directory
                if [ ! -s "$out" ] && [ -s "$out.dir" ]; then
                    mv "$out.dir" "$out"
                else
                    rm -f "$out.dir"
                fi
            fi
        '';
      };
    })
  ];
}
