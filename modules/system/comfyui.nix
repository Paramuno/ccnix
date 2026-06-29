{ inputs, ... }:
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
  };
}
