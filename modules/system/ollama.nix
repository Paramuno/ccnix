{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    # NixOS will spawn a background 'ollama-model-loader.service' to pull models declaratively without blocking your boot process.
    loadModels = [
      "gemma4"
      "batiai/qwen3.6-35b:iq4"
    ];
  };
}
