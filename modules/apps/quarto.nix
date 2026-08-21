{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.apps.quarto;
in
{
  options.myModules.apps.quarto = {
    enable = lib.mkEnableOption "quarto";
    pdf = lib.mkEnableOption "LaTeX toolchain for PDF output";
    jupyter = lib.mkEnableOption "Jupyter engine for python cells";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.quarto.override {
        extraPythonPackages =
          ps:
          lib.optionals cfg.jupyter [
            ps.jupyter
            ps.nbclient
            ps.nbformat
          ];
      })
    ]
    ++ lib.optional cfg.pdf pkgs.texliveSmall;
  };
}
