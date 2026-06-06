{
  lib,
  pkgs,
  user,
  enabled,
  service,
  signalBridge,
  ...
}: let
  inherit (signalBridge)
    account
    bind
    port
    extraArgs
    ;
  serviceGroup = service.group;
  signalArgs =
    [
      "-a"
      account
      "daemon"
      "--http"
      "${bind}:${toString port}"
    ]
    ++ extraArgs;
in {
  home = lib.mkIf enabled {};
  nixos = lib.mkIf enabled {
    services.spacebot = {
      enable = true;
      pathUser = user;
      variant = service.variant;
      user = user;
      group = serviceGroup;
    };

    systemd.services.signal-cli-daemon = {
      description = "Signal CLI daemon for Spacebot";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      before = ["spacebot.service"];

      serviceConfig = {
        Type = "simple";
        User = user;
        Group = serviceGroup;
        WorkingDirectory = "/home/${user}";
        Environment = [
          "HOME=/home/${user}"
          "XDG_CONFIG_HOME=/home/${user}/.config"
          "XDG_DATA_HOME=/home/${user}/.local/share"
        ];
        ExecStart = "${pkgs.lib.getExe pkgs.signal-cli} ${builtins.concatStringsSep " " signalArgs}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    systemd.services.spacebot = {
      wants = ["signal-cli-daemon.service"];
      after = ["signal-cli-daemon.service"];
      requires = ["signal-cli-daemon.service"];
    };
  };
}
