{
  config,
  lib,
  pkgs,
  ...
}:

let
  pname = "pureref";
  version = "2.1.1";

  src = pkgs.fetchurl {
    url = "https://github.com/Paramuno/linux-binaries/releases/download/pureref-v2.1.1/PureRef-2.1.1_x64.Appimage";
    # Prefix the output from nix-prefetch-url with 'sha256-'
    hash = "sha256-U3dyoVX76l46W7ypGqj7Riqpb8Cb42aOtmaqD+WMcDU=";
  };

  appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
in
{
  options.myModules.apps.pureref.enable = lib.mkEnableOption "pureref";

  config = lib.mkIf config.myModules.apps.pureref.enable {
    home.packages = [
      (pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraPkgs =
          pkgs: with pkgs; [
            wayland
            libxkbcommon
          ];

        extraInstallCommands = ''
          install -m 444 -D ${appimageContents}/pureref.desktop -t $out/share/applications

          # Restored your original sed command 
          sed -i 's/^Exec=.*$/Exec=pureref %f/' $out/share/applications/pureref.desktop

          cp -r ${appimageContents}/usr/share/icons $out/share
        '';
      })
    ];
  };
}
