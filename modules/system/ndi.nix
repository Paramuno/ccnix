{ pkgs, ... }:
{

  services.avahi = {
    enable = true;
    nssmdns4 = true; # Allow resolution of .local domains
    publish = {
      enable = true;
      userServices = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # OBS wrapped with the directly overridden NDI plugin
    (wrapOBS {
      plugins = [
        (pkgs.obs-studio-plugins.distroav.override {
          ndi-6 = pkgs."ndi-6".overrideAttrs (old: {
            src = old.src.overrideAttrs (oldSrc: {
              # Forcefully inject both hash formats to satisfy the fetcher
              hash = "sha256-8DFPJFRG3vxIi2POtGiazxqWWu79ray3BXG7IWqMwYM=";
              outputHash = "sha256-8DFPJFRG3vxIi2POtGiazxqWWu79ray3BXG7IWqMwYM=";
            });
          });
        })
      ];
    })
  ];
}
