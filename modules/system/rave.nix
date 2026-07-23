# IRCAM RAVE — pinned uv venv inside an FHS sandbox (deps are unpackageable in nixpkgs)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.system.rave;

  pyproject = pkgs.writeText "rave-pyproject.toml" ''
    [project]
    name = "rave-env"
    version = "0"
    requires-python = "==3.11.*"
    dependencies = [
      "acids-rave==${cfg.version}",
      "numpy<2",
      "torch${cfg.torchSpec}",
      "torchaudio",
    ${lib.concatMapStrings (d: "  \"${d}\",\n") cfg.extraDeps}]
  '';

  rave = pkgs.buildFHSEnv {
    name = "rave";
    targetPkgs =
      p: with p; [
        python311
        uv
        ffmpeg-full
        git
        zlib
        libGL
        glib
        libsndfile
        stdenv.cc.cc.lib
      ];
    profile = ''
      export RAVE_HOME="''${RAVE_HOME:-$HOME/.local/share/rave}"
      export UV_PROJECT_ENVIRONMENT="$RAVE_HOME/venv"
      export UV_TORCH_BACKEND=${cfg.torchBackend}
      export LD_LIBRARY_PATH="/run/opengl-driver/lib:''${LD_LIBRARY_PATH:-}"
    '';
    runScript = pkgs.writeShellScript "rave-dispatch" ''
      set -euo pipefail
      install -Dm644${pyproject} "$RAVE_HOME/pyproject.toml"
      cd "$RAVE_HOME"
      [ -x "$UV_PROJECT_ENVIRONMENT/bin/rave" ] || uv sync
      case "''${1-}" in
        sync) shift; exec uv sync --upgrade "$@" ;;
        env)  shift; export PATH="$UV_PROJECT_ENVIRONMENT/bin:$PATH"; exec "$@" ;;
        *)    exec "$UV_PROJECT_ENVIRONMENT/bin/rave" "$@" ;;
      esac
    '';
  };
in
{
  options.myModules.system.rave = {
    enable = lib.mkEnableOption "IRCAM RAVE";
    version = lib.mkOption {
      type = lib.types.str;
      default = "2.3.1";
    };
    torchSpec = lib.mkOption {
      type = lib.types.str;
      default = ">=2.1,<2.6";
      description = "PEP 440 spec. Blackwell (RTX 5090, sm_120) requires >=2.7.";
    };
    torchBackend = lib.mkOption {
      type = lib.types.str;
      default = "auto"; # uv probes the driver; falls back to cpu
      description = "auto | cpu | cu124 | cu128";
    };
    extraDeps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ rave ];
  };
}
