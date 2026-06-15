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

  users.users.admin = {
    hashedPasswordFile = "/etc/admin.pass";
  };

  systemd.tmpfiles.rules = [
    "d /home/admin 0700 admin users - -"
  ];
}
