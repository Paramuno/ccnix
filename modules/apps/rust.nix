{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.apps.rust;
in
{
  options.myModules.apps.rust = {
    enable = lib.mkEnableOption "rust toolchain";
    lsp = (lib.mkEnableOption "rust-analyzer, clippy, rustfmt") // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        rustc
        cargo
        pkg-config # most -sys crates need it at build time
      ]
      ++ lib.optionals cfg.lsp [
        rust-analyzer
        clippy
        rustfmt
      ];

    # Keep ~/ clean; cargo install targets go to XDG data dir
    home.sessionVariables = {
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}"; # rust-analyzer std lookup
    };
    home.sessionPath = [ "${config.xdg.dataHome}/cargo/bin" ];
  };
}
