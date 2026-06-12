{
  config,
  lib,
  pkgs,
  ...
}:
let
  interface = "wlan0";
  gatewayIp = "10.0.0.1";

  startHereMd = pkgs.writeText "Start_Here.md" ''
    # Welcome to the PirateBox
    You are currently connected to an offline, anonymous mesh node.

    ## Core Infrastructure (Read Only)
    * [Rules of Engagement](core/rules_of_engagement.md)

    ## The Sandbox (Read/Write)
    * [General Discussion Board](community/general_discussion/index.md)
    * [Media](media/index.md)
  '';
in
{
  options.myModules.apps.broot.enable = lib.mkEnableOption "piratebox";
  config = lib.mkIf config.myModules.apps.broot.enable {

    # Disable standard networking managers on the AP interface
    networking = {
      networkmanager.unmanaged = [ interface ];
      wireless.enable = false;
      interfaces.${interface}.ipv4.addresses = [
        {
          address = gatewayIp;
          prefixLength = 24; # Static IP
        }
      ];
      firewall.interfaces.${interface}.allowedTCPPorts = [
        53
        80
      ];
      firewall.interfaces.${interface}.allowedUDPPorts = [
        53
        67
      ];
    };

    # ----

    # Directory must exist
    systemd.tmpfiles.rules = [
      "d /var/lib/piratebox/share 0777 root root -"
      "d /var/lib/piratebox/share/wiki 0755 root root -"

      # Core is strictly read-only for standard users
      "d /var/lib/piratebox/share/wiki/core 0755 root root -"

      # Community and Media are completely open sandboxes
      "d /var/lib/piratebox/share/wiki/community 0777 root root -"
      "d /var/lib/piratebox/share/wiki/media 0777 root root -"

      # Archive is owned by root, users cannot touch backups
      "d /var/lib/piratebox/share/wiki/archive 0750 root root -"

      "L+ /var/lib/piratebox/share/wiki/00_Start_Here.md - - - - ${startHereMd}"
    ];

    # ----

    # Access Point
    services = {
      hostapd = {
        enable = true;
        radios.${interface} = {
          band = "2g";
          channel = 6;
          networks.${interface} = {
            ssid = "PirateBox - Free Space";
            # Open network, no authentication
            authentication = {
              mode = "none";
            };
          };
        };
      };

      # DHCP and DNS Sinkhole
      dnsmasq = {
        enable = true;
        alwaysKeepRunning = true;
        settings = {
          interface = interface;
          listen-address = gatewayIp;
          bind-interfaces = true;
          # DHCP Range
          dhcp-range = "10.0.0.10,10.0.0.250,12h";
          # DNS Sinkhole: Resolve EVERYTHING to the local IP
          address = "/#/${gatewayIp}";
        };
      };

      # File Sharing Daemon
      filebrowser = {
        enable = true;
        address = "127.0.0.1";
        port = 8080;
        settings = {
          root = "/var/lib/piratebox/share";
          noauth = true; # Allow anonymous access
        };
      };

      # Nginx and Captive Portal Routing
      nginx = {
        enable = true;
        virtualHosts."_" = {
          default = true;
          listen = [
            {
              addr = gatewayIp;
              port = 80;
            }
          ];

          locations."/" = {
            return = "302 http://${gatewayIp}/files"; # Redirect all requests not matching /files to the portal
          };

          locations."/files" = {
            proxyPass = "http://127.0.0.1:8080";
            proxyWebsockets = true;
          };

          # Captive Portal specific endpoints for Apple/Android devices
          locations."/generate_204" = {
            return = "302 http://${gatewayIp}/files";
          };
          locations."/hotspot-detect.html" = {
            return = "302 http://${gatewayIp}/files";
          };
        };
      };
    };

  };
}
