{
  pkgs,
  lib,
  ...
}:
{
  # ── Nix Settings ────────────────────────────────────────────────────
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # ── Boot ────────────────────────────────────────────────────────────
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # ── Locale ──────────────────────────────────────────────────────────
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # ── Cache ──────────────────────────────────────────────────────

  nix.settings = {
    substituters = [
      "https://comfyui.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "comfyui.cachix.org-1:33mf9VzoIjzVbp0zwj+fT51HG0y31ZTK3nzYZAX0rec="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # ── Networking ──────────────────────────────────────────────────────
  networking = {
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    firewall = {
      trustedInterfaces = [ "tailscale0" ];
      interfaces."tailscale0".allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [
        41641 # tailscale
        5353 # NDI Avahi
      ];
      allowedTCPPortRanges = [
        {
          from = 5960;
          to = 5970;
        }
      ]; # NDI Avahi
      checkReversePath = "loose";
    };
  };

  # Virtual network for easy SSH
  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--ssh" ];
  };

  # ── Services & programs ──────────────────────────────────────────────────────
  programs.zsh.enable = true;
  services.printing.enable = true;
  services.kanata = {
    enable = true;
    package = pkgs.kanata.override { withCmd = true; };
    keyboards = {
      default = {
        # 1. SCOPE: Lock Kanata to ONLY your specific keyboard
        devices = [
          "/dev/input/by-id/usb-CHERRY_CHERRY_Wireless_Device-event-kbd"
        ];

        # 2. CONFIG: Point directly to your Home Manager file using a relative path
        configFile = ../../static/kanata/config-nixos.kbd;

        # 3. SCRIPTS: Open the TCP port for hyprkan
        extraArgs = [
          "-p"
          "10000"
        ];
      };
    };
  };
  # Override the strict security sandbox to allow Kanata to open a TCP port for hyprkan.py
  systemd.services.kanata-default.serviceConfig.RestrictAddressFamilies = pkgs.lib.mkForce [
    "AF_UNIX"
    "AF_INET"
    "AF_INET6"
  ];

  environment.systemPackages = with pkgs; [
    brightnessctl
    firefox
  ];

  # ── Opts ──────────────────────────────────────────────────────

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    config.hardware.nvidia.package
  ];
}
