{
  type = "nixos";
  name = "cc3";
  hostPlatform = "x86_64-linux";
  user = "admin";

  modules = [
    ../hosts/cc3/cc3-config.nix
    ../hosts/cc3/disko.nix
    ../hosts/cc3/hardware-configuration.nix
  ];

  homeModules = [
    ../hosts/cc3/cc3.nix
  ];

  deployment = {
    targetHost = "cc3.tailf072cc.ts.net";
    targetUser = "root";
    allowLocalDeployment = true;

    # these tags can be used as filters for colmena apply --on @mytag
    tags = [
      "workstation"
      "linux"
    ];
  };
}
