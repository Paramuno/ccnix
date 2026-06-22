{
  config,
  pkgs,
  ...
}:
{
  imports = [
    # Eventually change to optin structure for parity with apps
    ../../modules/profiles/admin.nix
    ../../modules/system/audio-config.nix
    ../../modules/system/core-config.nix
    ../../modules/system/gui-config.nix
    ../../modules/system/ndi.nix
  ];

  networking.hostName = "cc1";
  system.stateVersion = "26.05";

  # ── GPU & Hardware ──────────────────────────────────────────────────
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true; # Modesetting is required for Wayland and Hyprland
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    # Use the NVidia open source kernel module (Recommended for RTX 20-series+) not noveau driver
    open = true;
    nvidiaSettings = true; # Enable the Nvidia settings menu, via `nvidia-settings`.
    package = config.boot.kernelPackages.nvidiaPackages.stable; # (stable, beta, production, etc.)
  };

  # ── Alle user ──────────────────────────────────────────────────
  users.users.alle = {
    isNormalUser = true;
    description = "alle";
    hashedPasswordFile = "/etc/alle.pass";
    shell = pkgs.bash; # or pkgs.zsh if you want
    home = "/home/alle";
    createHome = true;
    extraGroups = [
      "networkmanager"
      "video"
      "audio"
    ];
  };
  # services.displayManager.autoLogin = {
  #   enable = true;
  #   user = "alle";
  # };

  # ── Services & programs ────────────────────────────────────────────────────────
  # For Bottles
  services.flatpak.enable = true;
  fonts.packages = with pkgs; [
    corefonts
    vista-fonts # Optional: Adds Calibri, Consolas, etc.
  ];

  environment.systemPackages = with pkgs; [
    # ollama
  ];
}
