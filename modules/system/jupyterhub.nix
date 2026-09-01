{ pkgs, ... }:
let
  admins = [ "alle" ]; # PAM logins allowed to reach the hub
  kernelEnv = pkgs.python3.withPackages (p: [
    p.ipykernel
    p.numpy
    p.pandas
    p.matplotlib
  ]);
in
{
  services.jupyterhub = {
    enable = true;
    host = "127.0.0.1"; # reach it via SSH tunnel over tailscale
    port = 8000;
    authentication = "jupyterhub.auth.PAMAuthenticator";
    spawner = "systemdspawner.SystemdSpawner"; # one systemd unit per user

    kernels.python3 = {
      displayName = "Python 3";
      language = "python";
      argv = [
        "${kernelEnv}/bin/python"
        "-m"
        "ipykernel_launcher"
        "-f"
        "{connection_file}"
      ];
      logo32 = "${kernelEnv}/${kernelEnv.sitePackages}/ipykernel/resources/logo-32x32.png";
      logo64 = "${kernelEnv}/${kernelEnv.sitePackages}/ipykernel/resources/logo-64x64.png";
    };

    extraConfig = ''
      c.Authenticator.allowed_users = {${builtins.concatStringsSep ", " (map (u: "'${u}'") admins)}}
      c.Authenticator.admin_users = {${builtins.concatStringsSep ", " (map (u: "'${u}'") admins)}}
      c.SystemdSpawner.mem_limit = '8G'
      c.SystemdSpawner.dynamic_users = False
    '';
  };
}
