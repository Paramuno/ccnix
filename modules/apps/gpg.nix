{
  config,
  lib,
  pkgs,
  isNixOS,
  ...
}:

{
  options.myModules.apps.gpg.enable = lib.mkEnableOption "gpg";

  config = lib.mkIf config.myModules.apps.gpg.enable {

    home.sessionVariables = {
      GNUPGHOME = "${config.home.homeDirectory}/.local/share/gnupg";
    };

    home.packages = with pkgs; [
      pass
    ];

    programs.gpg = {
      enable = true;
      homedir = "${config.home.homeDirectory}/.local/share/gnupg";
    };

    services.gpg-agent = {
      enable = true;
      pinentry.package = if isNixOS then pkgs.pinentry-tty else pkgs.pinentry-rofi;

      # pinentry.package = pkgs.pinentry-tty;
      # pinentry.package = pkgs.pinentry-rofi;

      # Keep the vault unlocked in RAM for 1 hour (3600 seconds) after initial unlock
      defaultCacheTtl = 3600;

      # Maximum time before a forced re-prompt, regardless of recent activity (24 hours)
      maxCacheTtl = 86400;

      # Optional: Enable SSH support to allow using GPG keys for SSH authentication
      # if you decide to consolidate your cryptographic keys in the future.
      enableSshSupport = true;
    };
  };
}
