{ config, lib, pkgs, ... }:
{
  options.myModules.apps.t3code.enable = lib.mkEnableOption "t3code";
  config = lib.mkIf config.myModules.apps.t3code.enable (
    let
      t3-appimage-src = pkgs.fetchurl {
        url = "https://github.com/pingdotgg/t3code/releases/download/v0.0.20/T3-Code-0.0.20-x86_64.AppImage";
        sha256 = "1vl0drr8c233j84cjvd4r342sm0y73wvl2cmmqmwxrh0qlbjfml2";
      };

      t3-code-base = pkgs.appimageTools.wrapType2 {
        pname = "t3-code";
        version = "0.0.20";
        src = t3-appimage-src;
      };

      t3-code-launcher = pkgs.writeShellScriptBin "t3-code" ''
        exec ${t3-code-base}/bin/t3-code --enable-features=UseOzonePlatform --ozone-platform=wayland --no-sandbox --force-device-scale-factor=1.25 "$@"
      '';

      t3-code-desktop = pkgs.makeDesktopItem {
        name = "t3-code";
        desktopName = "T3 Code";
        genericName = "AI Coding Agent";
        exec = "t3-code";
        icon = "utilities-terminal";
        terminal = false;
        categories = [ "Development" "Utility" ];
      };
    in
    {
      home.packages = with pkgs; [
        t3-code-launcher
        t3-code-desktop
      ];
    }
  );
}
