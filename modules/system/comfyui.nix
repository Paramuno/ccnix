{ inputs, pkgs, ... }:
{
  imports = [ inputs.comfyui-nix.nixosModules.default ];
  nixpkgs.overlays = [ inputs.comfyui-nix.overlays.default ];

  services.comfyui = {
    enable = true;
    gpuSupport = "cuda";
    enableManager = true;
    dataDir = "/var/lib/comfyui";
    listenAddress = "127.0.0.1"; # reach it via SSH tunnel over tailscale
    openFirewall = false;
    extraArgs = [ "--use-sage-attention" ];

    customNodes = {
      ComfyUI-Custom-Scripts = pkgs.fetchFromGitHub {
        owner = "pythongosssss";
        repo = "ComfyUI-Custom-Scripts";
        rev = "609f3afaa74b2f88ef9ce8d939626065e3247469";
        hash = "sha256-2GgTS7l/sMSnJb07sBifL8NGnDBF3g9qdlSKr3gYFGQ="; # placeholder, fill in below
      };
      ComfyUI-Z-Image-Turbo-Resolutions = pkgs.fetchFromGitHub {
        owner = "SaTaNoob";
        repo = "ComfyUI-Z-Image-Turbo-Resolutions";
        rev = "16d043905613ed085daaf4f6f339978a6a2ab86d";
        hash = "sha256-3I4yKOf5GOefSUjZHDnvV91PO553mGZLPcffxs9UsrI="; # fill in below
      };
    };
  };
}
