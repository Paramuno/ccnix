{
  type = "nixos";
  name = "cc1";
  hostPlatform = "x86_64-linux";
  user = "admin";

  modules = [
    ../hosts/cc1/cc1-config.nix
    ../hosts/cc1/disko.nix
    ../hosts/cc1/hardware-configuration.nix
  ];

  homeModules = [
    ../hosts/cc1/cc1.nix
  ];

  deployment = {
    targetHost = "10.10.2.13";
    targetUser = "root";
    allowLocalDeployment = true;

    # these tags can be used as filters for colmena apply --on @mytag
    tags = [
      "workstation"
      "linux"
    ];
  };
}
