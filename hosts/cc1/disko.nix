{
  disko.devices = {
    disk = {
      cosmos-disk = {
        type = "disk";
        device = "/dev/disk/by-id/a5f1492c-f60d-489c-9902-91e545dd3c38";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
# lsblk -- Look for primary internal disk
# sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
#   --write-efi-boot-entries \
#   --flake 'github:paramuno/yourrepo#new-host' \
#   --disk main /dev/nvme0n1 or /dev/sda:sdb
