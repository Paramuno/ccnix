{ inputs }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nur
    nix-flatpak
    ;

  # Single source of truth for a nixos node's module set.
  # Consumed by both nixosSystem and colmena.
  nixosModulesFor =
    node:
    node.modules
    ++ [
      { nixpkgs.overlays = [ nur.overlays.default ]; }
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = {
            inherit inputs;
            isNixOS = true;
            hostName = node.name;
            username = node.user;
          };
          users.${node.user}.imports = node.homeModules ++ [ nix-flatpak.homeManagerModules.nix-flatpak ];
        };
      }
    ];

  build =
    node:
    if node.type == "nixos" then
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = node.user;
        }
        // (node.specialArgs or { });

        modules = [
          { nixpkgs.hostPlatform = node.hostPlatform; }
        ]
        ++ nixosModulesFor node;
      }

    else if node.type == "home-manager" then
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = node.hostPlatform;
          overlays = [ nur.overlays.default ];
        };
        extraSpecialArgs = {
          inherit inputs;
          isNixOS = false;
          username = node.user;
        };
        modules = node.homeModules ++ [ nix-flatpak.homeManagerModules.nix-flatpak ];
      }

    else
      throw "mkNode: unknown node.type '${node.type}'";
in
{
  inherit build nixosModulesFor;
}
