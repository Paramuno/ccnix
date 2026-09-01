{
  config,
  lib,
  pkgs,
  ...
}:
# Miniconda is unfree + dynamically linked: it only works inside an FHS env.
# Enter it with `conda-shell`, then use `conda` normally.
let
  cfg = config.myModules.apps.miniconda;
in
{
  options.myModules.apps.miniconda = {
    enable = lib.mkEnableOption "miniconda (FHS-wrapped)";
    installPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.dataHome}/conda";
      description = "Where the miniconda installer bootstraps itself";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.conda.override {
        installationPath = cfg.installPath;
        extraPkgs = with pkgs; [
          gcc
          zlib
          git
        ];
      })
    ];
  };
}
