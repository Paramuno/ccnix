{ pkgs, ... }:
{
  users.users.admin = {
    hashedPasswordFile = "/etc/admin.pass";
    isNormalUser = true;
    description = "admin";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "uinput"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9zHr4+PtAx3W18a/g96OarrbxPlh3r+4RpWLYPCWFI"
    ];
  };

  users.users.root = {
    hashedPasswordFile = "/etc/admin.pass";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9zHr4+PtAx3W18a/g96OarrbxPlh3r+4RpWLYPCWFI"
    ];
  };
  security.sudo.wheelNeedsPassword = true;

  systemd.tmpfiles.rules = [
    "d /home/admin 0700 admin users - -"
  ];
}
