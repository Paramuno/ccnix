{ config, lib, ... }:
{
  options.myModules.apps.ssh.enable = lib.mkEnableOption "ssh";
  config = lib.mkIf config.myModules.apps.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          hashKnownHosts = true;
          extraOptions = {
            IgnoreUnknown = "GSSAPIKexAlgorithms,GSSAPIAuthentication";
            ControlMaster = "auto";
            # ControlPath = "~/.ssh/%r@%h:%p";
            ControlPath = "~/.ssh/master-%C"; # %C safe variable
            ControlPersist = "10m";
          };
        };
        "imac" = {
          hostname = "imac.tailf072cc.ts.net";
          user = "mar";
          extraOptions = {
            RequestTTY = "force";
          };
        };
        "nixos" = {
          hostname = "nixos.tailf072cc.ts.net";
          user = "mar";
          extraOptions = {
            RequestTTY = "force";
          };
        };
        "fedora" = {
          hostname = "fedora.tailf072cc.ts.net";
          user = "mar";
          extraOptions = {
            RequestTTY = "force"; # This is crucial for the v fzf function
            # RemoteCommand = "zellij attach --create fedora";
          };
        };
      };
    };
  };
}
