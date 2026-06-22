{
  type = "nixos";
  name = "cc4";
  hostPlatform = "x86_64-linux";
  user = "admin";

  modules = [
    ../hosts/cc4/cc4-config.nix
    ../hosts/cc4/hardware-configuration.nix
  ];

  homeModules = [
    ../hosts/cc4/cc4.nix
  ];

  deployment = {
    targetHost = "cc4.tail92efad.ts.net";
    targetUser = "root";
    allowLocalDeployment = true;

    # these tags can be used as filters for colmena apply --on @mytag
    tags = [
      "workstation"
      "linux"
    ];
  };
}
