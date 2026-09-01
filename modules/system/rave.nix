{ config, lib, pkgs, ... }:
# Wraps RAVE's uv venv with LD_LIBRARY_PATH so unpatched wheels (numpy, torch)
# find libstdc++ / libsndfile / libcuda. nix-ld does not cover venv pythons.
let
  cfg = config.myModules.system.rave;

  libPath = lib.makeLibraryPath (
    with pkgs;
    [
      stdenv.cc.cc.lib # libstdc++.so.6
      zlib
      zstd
      libsndfile
      ffmpeg
      sox
      libGL
      glib
    ]
    ++ cfg.extraLibraries
  );

  rave = pkgs.writeShellApplication {
    name = "rave";
    runtimeInputs = [ pkgs.uv ];
    text = ''
      export LD_LIBRARY_PATH="${libPath}:/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      venv="''${RAVE_VENV:-${cfg.venvDir}}"

      if [ ! -x "$venv/bin/rave" ]; then
        uv venv --python "${cfg.python}/bin/python" "$venv"
        VIRTUAL_ENV="$venv" uv pip install \
          --torch-backend=${cfg.torchBackend} \
          "torch${cfg.torchSpec}" acids-rave
      fi

      exec "$venv/bin/rave" "$@"
    '';
  };
in
{
  options.myModules.system.rave = {
    enable = lib.mkEnableOption "rave";

    torchSpec = lib.mkOption {
      type = lib.types.str;
      default = ">=2.7";
      description = "PEP 440 version spec passed to `uv pip install torch`.";
    };

    torchBackend = lib.mkOption {
      type = lib.types.str;
      default = "cu128";
      description = "uv --torch-backend value (cu128, cu126, cpu, auto).";
    };

    python = lib.mkOption {
      type = lib.types.package;
      default = pkgs.python312;
      description = "Interpreter used to seed the venv.";
    };

    venvDir = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.local/share/rave/venv";
      description = "Venv location; override per-invocation with $RAVE_VENV.";
    };

    extraLibraries = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra libraries appended to LD_LIBRARY_PATH.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      rave
      pkgs.uv
    ];
  };
}
