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
    ../../modules/system/ollama.nix
    ../../modules/system/opencode.nix
    ../../modules/system/rave.nix
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
  # Rave config
  myModules.system.rave = {
    enable = true;
    torchSpec = ">=2.7";
    torchBackend = "cu128";
  };

  # ── Alle user ──────────────────────────────────────────────────
  users.users.alle = {
    isNormalUser = true;
    description = "alle";
    hashedPasswordFile = "/etc/alle.pass";
    shell = pkgs.zsh;
    # shell = pkgs.bash;
    home = "/home/alle";
    createHome = true;
    extraGroups = [
      "networkmanager"
      "video"
      "audio"
    ];
  };
  home-manager.users.alle = {
    imports = [
      ../../modules/apps/fzf.nix
      ../../modules/apps/git.nix
      ../../modules/apps/kitty.nix
      ../../modules/apps/lazygit.nix
      ../../modules/apps/pi.nix
      ../../modules/apps/ssh.nix
      ../../modules/apps/starship.nix
      ../../modules/apps/t3code.nix
      ../../modules/apps/zsh.nix

      ../../modules/bundles/dotfiles.nix
      ../../modules/bundles/nix-packages.nix
      ../../modules/bundles/packages.nix
    ];
    home.stateVersion = "25.05";
    # home.packages = [ pkgs.kitty ]; # kitty.nix ships config only; binary lives in nix-packages bundle alle won't get
    myModules.apps = {
      fzf.enable = true;
      git.enable = true;
      kitty.enable = true;
      lazygit.enable = true;
      pi.enable = true;
      ssh.enable = true;
      starship.enable = true;
      t3code.enable = true;
      zsh.enable = true;
    };
  };

  # ── Services & programs ────────────────────────────────────────────────────────
  # For Bottles
  services.flatpak.enable = true;
  fonts.packages = with pkgs; [
    corefonts
    vista-fonts # Optional: Adds Calibri, Consolas, etc.
  ];

  systemd.services.comfyui-serve = {
    after = [
      "tailscaled.service"
      "comfyui.service"
    ];
    requires = [ "comfyui.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = 30;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 http://127.0.0.1:8188";
      ExecStop = "${pkgs.tailscale}/bin/tailscale serve --https=443 off";
    };
  };

  environment.systemPackages = with pkgs; [
    ollama
    google-chrome
    vlc
    libreoffice
    blender
    reaper
    davinci-resolve
    arduino
    processing
    puredata
    audacity
    bitwig-studio
    supercollider-with-sc3-plugins
  ];
}
