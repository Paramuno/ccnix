{
  type = "nixos";
  name = "cc2";
  hostPlatform = "x86_64-linux";
  user = "admin";

  modules = [
    ../hosts/cc2/cc2-config.nix
    ../hosts/cc2/disko.nix
    ../hosts/cc2/hardware-configuration.nix
  ];

  homeModules = [
    ../hosts/cc2/cc2.nix
  ];

  deployment = {
    targetHost = "cc2.tail92efad.ts.net";
    targetUser = "root";
    allowLocalDeployment = true;

    # these tags can be used as filters for colmena apply --on @mytag
    tags = [
      "workstation"
      "linux"
    ];
  };
}
