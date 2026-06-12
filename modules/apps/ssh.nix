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
        # "pc" = {
        #   hostname = "pc.tailf072cc.ts.net";
        #   user = "admin";
        #   extraOptions = {
        #     RequestTTY = "force";
        #   };
        # };
      };
    };
  };
}
