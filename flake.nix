{
  description = "NixOS & Fedora Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest"; # Declarative partition modification & mounting
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest"; # flatpacks
    agenix.url = "github:ryantm/agenix"; # agenix secrets colmena

    # Particular sources
    ags.url = "github:Aylur/ags/v1";
    nix-claude-code.url = "github:ryoppippi/nix-claude-code";
    opencode.url = "github:anomalyco/opencode";
    zjstatus.url = "github:dj95/zjstatus";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-flatpak,
      nur,
      nix-claude-code,
      ...
    }@inputs:
    let
      system = "x86_64-linux"; # Adjust to aarch64-linux if on ARM
      pkgs = import nixpkgs {
        inherit system;
      };
      lib = nixpkgs.lib;

      nodes = {
        cc1 = import ./nodes/cc1-node.nix;
        cc2 = import ./nodes/cc2-node.nix;
        cc3 = import ./nodes/cc3-node.nix;
        cc4 = import ./nodes/cc4-node.nix;
      };

      mkNode = import ./lib/mkNode.nix { inherit inputs; };
      byType = t: lib.filterAttrs (_: n: n.type == t) nodes;

    in
    {
      # ==========================================
      # 0. DIRENV FOR THIS REPO
      # ==========================================

      devShells.${system}.default = pkgs.mkShell {
        name = "dotfiles-shell";

        # These packages will only be available in your PATH when
        # you are inside this repository.
        packages = with pkgs; [
          tree-sitter
          nil # Nix
          nixfmt
          kdlfmt
          statix
          deadnix
          lua-language-server # Lua
          stylua
          vscode-langservers-extracted # JSON / YAML / HTML
          yaml-language-server
          marksman # markdown
          taplo # TOML
          bash-language-server # Bash / Shell scripts
          shfmt
          prettier # Generic formatters
        ];
      };

      # ==========================================
      # COLMENA NODE SETUP
      # ==========================================

      nixosConfigurations =
        lib.mapAttrs (name: node: mkNode.build (node // { inherit name; })) (byType "nixos")
        // {
          installer = lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              inputs.disko.nixosModules.disko
              ./hosts/installer/installer.nix
            ];
          };
        };

      # homeConfigurations."<user>@<name>" — preserves existing flake ref
      homeConfigurations = lib.mapAttrs' (
        name: node: lib.nameValuePair "${node.user}@${name}" (mkNode.build node)
      ) (byType "home-manager");

      # Colmena — drop-in when ready:

      colmena = {
        meta = {
          nixpkgs = pkgs;
          specialArgs = { inherit inputs; };
        };
      }
      // lib.mapAttrs (name: node: {
        imports = (mkNode.nixosModulesFor (node // { inherit name; }));
        deployment = node.deployment;
      }) (byType "nixos");

    };
}
