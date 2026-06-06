{
  pkgs,
  user,
  ...
}: let
  wgConfig = "/home/${user}/.config/vpn/ca-awg.conf";
in {
  output = {
    name = "caelestia";
    executable = "caelestia-shell";
    programSystemd = {
      enable = false;
      target = "graphical-session.target";
      environment = [];
    };
    settingsOverrides = {
      utilities.vpn = {
        enabled = true;
        provider = [
          {
            name = "custom";
            displayName = "Canada VPN (Fast)";
            interface = "ca-awg";
            enabled = true;
            connectCmd = [
              "pkexec"
              "${pkgs.wireguard-tools}/bin/wg-quick"
              "up"
              wgConfig
            ];
            disconnectCmd = [
              "pkexec"
              "${pkgs.wireguard-tools}/bin/wg-quick"
              "down"
              wgConfig
            ];
          }
        ];
      };
    };
  };
}
