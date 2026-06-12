{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.pi.enable = lib.mkEnableOption "pi";
  config = lib.mkIf config.myModules.apps.pi.enable {
    home.packages = [
      # Creates a localized transient binary wrapper using node/npx
      (pkgs.writeShellScriptBin "pi" ''
        exec ${pkgs.nodejs}/bin/npx --yes @earendil-works/pi-coding-agent "$@"
      '')
    ];

    # Hardwires your Ollama/Gemma4 definition strictly on this node
    home.file.".pi/agent/models.json".text = builtins.toJSON {
      providers = {
        ollama = {
          baseUrl = "http://localhost:11434/v1";
          api = "openai-completions";
          apiKey = "ollama";
          models = [
            {
              id = "gemma4"; # Ensure this string matches your local `ollama list` output
              name = "Gemma 4 (Local)";
              contextWindow = 262144;
              supportsImages = false;
              supportsTools = true;
            }
            {
              id = "batiai/qwen3.6-35b:iq4";
              name = "Qwen 3.6 35B (IQ4)";
              contextWindow = 131072; # Qwen 3.6 native context window size
              supportsImages = false;
              supportsTools = true; # Qwen 3.6 has native high-tier tool-calling capabilities
            }
          ];
        };
      };
    };

  };
}
