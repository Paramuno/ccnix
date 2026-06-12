{ config, lib, pkgs, ... }:
{
  options.myModules.apps.zotero.enable = lib.mkEnableOption "zotero";
  config = lib.mkIf config.myModules.apps.zotero.enable (
    let
      zoteroPluginList = builtins.fromJSON (builtins.readFile ../../static/releases/zotero-plugins.json);
    in
    {
      home.packages = with pkgs; [
        (symlinkJoin {
          name = "zotero-wrapped";
          paths = [ zotero ];
          buildInputs = [ makeWrapper ];
          postBuild = ''
                    wrapProgram $out/bin/zotero \
            --set HOME "${config.home.homeDirectory}//.local/share/zotero-generated" \
                      --add-flags "-profile ${config.home.homeDirectory}/.config/zotero"
          '';
        })
      ];

      # xdg.configFile."zotero/extensions/better-bibtex@retorque.re.xpi".source = builtins.fetchurl {
      #   url = zoteroPluginList."better-bibtex".url;
      #   sha256 = zoteroPluginList."better-bibtex".hash;
      # };

      xdg.configFile."zotero/extensions/better-bibtex@retorque.re.xpi".source = pkgs.fetchurl {
        inherit (zoteroPluginList."better-bibtex") url hash;
      };
    }
  );
}
