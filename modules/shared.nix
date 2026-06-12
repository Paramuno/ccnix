{
  lib,
  inputs,
  isNixOS,
  username,
  ...
}:
let
  # Dynamically discover and return all .nix files in a directory.
  getNixFiles =
    path:
    builtins.map (file: (path + "/${file}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (name: type: (type == "regular" && lib.strings.hasSuffix ".nix" name)) (
          builtins.readDir path
        )
      )
    );
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Enable on main dev machine
  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;

  # NixOS inherits allowUnfree globally from configuration.nix; Fedora requires it here
  nixpkgs.config = lib.mkIf (!isNixOS) {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  imports = [
    # External HM module — must come before programs.ags is referenced
    inputs.ags.homeManagerModules.default
  ]
  ++ getNixFiles ./bundles # Change them inside so that they're opt-in
  ++ getNixFiles ./apps; # Expose all apps folder as a possibility
}
