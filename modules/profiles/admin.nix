{ pkgs, ... }:
{
  users.users.admin = {
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
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
  ];

  users.users.admin.hashedPasswordFile = "/etc/admin.pass";
  users.users.root.hashedPasswordFile = "/etc/admin.pass";
  security.sudo.wheelNeedsPassword = true;

  systemd.tmpfiles.rules = [
    "d /home/admin 0700 admin users - -"
  ];
}
