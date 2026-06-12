{ config, lib, pkgs, ... }:
{
  options.myModules.apps.mpv.enable = lib.mkEnableOption "mpv";
  config = lib.mkIf config.myModules.apps.mpv.enable (
    let
      cookiePath = "~/.local/share/yt-dlp/cookies.txt";

      mpv-clipboard = pkgs.writeShellApplication {
        name = "mpv-clipboard";
        runtimeInputs = with pkgs; [
          mpv
          yt-dlp
          nodejs
          wl-clipboard
          libnotify
        ];
        text = ''
          URL=$(wl-paste)
          [[ -z "$URL" ]] && notify-send "mpv-clipboard" "Clipboard empty" && exit 1
          notify-send "Fetching Video..." "$URL"
          mpv --no-terminal "$URL" &
          disown
        '';
      };
    in
    {
      home.packages = [
        pkgs.mpv
        pkgs.yt-dlp
        mpv-clipboard
      ];
      xdg.configFile."mpv".source = ../../static/mpv;

      # Weekly cookie refresh from firefox
      systemd.user.services.yt-dlp-cookie-refresh = {
        Unit.Description = "Refresh yt-dlp cookies from Brave";
        Service = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.local/share/yt-dlp";
          ExecStart = toString [
            "${pkgs.yt-dlp}/bin/yt-dlp"
            "--cookies-from-browser"
            "firefox"
            "--cookies"
            "%h/.local/share/yt-dlp/cookies.txt"
            "--skip-download"
            "https://www.youtube.com"
          ];
        };
      };

      systemd.user.timers.yt-dlp-cookie-refresh = {
        Unit.Description = "Refresh yt-dlp cookies weekly";
        Timer = {
          OnCalendar = "weekly";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    }
  );
}
