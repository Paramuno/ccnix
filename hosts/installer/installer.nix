{
  pkgs,
  lib,
  modulesPath,
  inputs,
  ...
}:
let
  target = "cc1";
  disk = "/dev/disk/by-id/nvme-CT4000T705SSD3_2452E99CE8AD";
in
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  nixpkgs.config.allowUnfree = true;
  networking.wireless.enable = lib.mkForce false;

  # Salted hash only (not a private key). Impure read at build, lives ISO-local.
  environment.etc."seed/admin.pass" = {
    source = builtins.path {
      path = "/etc/nixos-keys/${target}-pass";
      name = "${target}-pass";
    };
    mode = "0600";
  };

  systemd.services.autoinstall = {
    description = "Unattended install of ${target}";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig.ConditionPathExists = "!/run/installed";
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "infinity";
    };
    path = with pkgs; [
      nix
      util-linux
      coreutils
    ];
    script = ''
      set -euo pipefail
      exec > /dev/tty1 2>&1
      d=$(readlink -f ${disk}) || { echo "target ${disk} not found"; exit 1; }
      lsblk -nro MOUNTPOINTS "$d" | grep -q . && { echo "refusing: $d has mounted partitions"; exit 1; }
      install -Dm600 /etc/seed/admin.pass /tmp/seed/etc/admin.pass
      echo ">>> Installing ${target} -> $d in 10s (Ctrl-C aborts)"; sleep 10
      nix run github:nix-community/disko/latest#disko-install -- \
        --write-efi-boot-entries \
        --flake ${inputs.self}#${target} \
        --disk cclab-disk ${disk} \
        --extra-files /tmp/seed/etc/admin.pass /etc/admin.pass
      touch /run/installed
      echo ">>> Done. Rebooting in 5s"; sleep 5; reboot
    '';
  };
}
