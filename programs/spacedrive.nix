{
  lib,
  pkgs,
  user,
  enabled,
  ...
}: let
  httpPort = 18080;
  serverPort = 18081;
  p2pPort = 7373;
in {
  home = lib.mkIf enabled {
    home.packages = with pkgs; [ spacedrive];
  };
  nixos = lib.mkIf enabled {
 

    # services.caddy = {
    #   enable = true;
    #   virtualHosts.":${toString httpPort}" = {
    #     extraConfig = ''
    #       reverse_proxy /rpc* localhost:${toString serverPort}
    #       reverse_proxy /health* localhost:${toString serverPort}
    #       respond / "Spacedrive v2 server is running (RPC-only). Use desktop/mobile client; web UI is not published yet." 200
    #       respond "Spacedrive v2 server is running (RPC-only). Use desktop/mobile client; web UI is not published yet." 200
    #     '';
    #   };
    # };
    # systemd.services.spacedrive-server = {
    #   description = "Spacedrive v2 server (headless RPC)";
    #   wantedBy = ["multi-user.target"];
    #   after = ["network-online.target"];
    #   wants = ["network-online.target"];
    #   serviceConfig = {
    #     Type = "simple";
    #     User = user;
    #     Group = "users";
    #     WorkingDirectory = "/home/${user}/spacedrive";
    #     ExecStart = "${pkgs.spacedrive_server_v2}/bin/sd-server --data-dir /home/${user}/spacedrive/.spacedrive-data --port ${toString serverPort}";
    #     Restart = "on-failure";
    #     RestartSec = "5s";
    #   };
    #   environment = {
    #     SD_AUTH = "disabled";
    #     SD_P2P = "true";
    #   };
    # };
    # systemd.tmpfiles.rules = [
    #   "d /home/${user}/spacedrive 0755 ${user} users -"
    #   "d /home/${user}/spacedrive/.spacedrive-data 0755 ${user} users -"
    # ];
    # networking.firewall.allowedTCPPorts = [
    #   httpPort
    #   serverPort
    # ];
    # networking.firewall.allowedUDPPorts = [p2pPort];
  };
}
