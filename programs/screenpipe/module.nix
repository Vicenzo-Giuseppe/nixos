{
  lib,
  pkgs,
  user,
  packageConfig,
  serviceName ? "screenpipe",
  dataDir,
  port ? 3030,
  webviewHost ? "127.0.0.1",
  webviewPort ? 3031,
  webviewAllowRawSql ? false,
  webviewMediaScanLimit ? 700,
  webviewExtraMediaDirs ? [],
  extraArgs ? [],
  enabled,
  ...
}: let
  inherit (packageConfig) package runtimeInputs homePackages webviewPackage;

  waylandSessionRunner = pkgs.writeShellApplication {
    name = "screenpipe-wayland-session";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
      set -euo pipefail

      if [ "$#" -lt 1 ]; then
        echo "usage: screenpipe-wayland-session <command> [args...]" >&2
        exit 64
      fi

      export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

      if [ -z "''${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -S "$XDG_RUNTIME_DIR/bus" ]; then
        export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
      fi

      if systemd_env="$(${pkgs.systemd}/bin/systemctl --user show-environment 2>/dev/null)"; then
        while IFS= read -r line; do
          [ -n "$line" ] || continue
          key="''${line%%=*}"
          value="''${line#*=}"

          case "$key" in
            DBUS_SESSION_BUS_ADDRESS|DISPLAY|HYPRLAND_INSTANCE_SIGNATURE|WAYLAND_DISPLAY|XDG_CURRENT_DESKTOP|XDG_RUNTIME_DIR|XDG_SESSION_TYPE)
              if [ -z "''${!key:-}" ]; then
                export "$key=$value"
              fi
              ;;
          esac
        done <<EOF
      $systemd_env
      EOF
      fi

      if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
        for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
          [ -S "$socket" ] || continue
          export WAYLAND_DISPLAY="''${socket##*/}"
          break
        done
      fi

      if [ -z "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -d "$XDG_RUNTIME_DIR/hypr" ]; then
        for session in "$XDG_RUNTIME_DIR"/hypr/*; do
          [ -d "$session" ] || continue
          export HYPRLAND_INSTANCE_SIGNATURE="''${session##*/}"
          break
        done
      fi

      export XDG_CURRENT_DESKTOP="''${XDG_CURRENT_DESKTOP:-Hyprland}"
      export XDG_SESSION_TYPE="''${XDG_SESSION_TYPE:-wayland}"

      exec "$@"
    '';
  };

  screenpipePath = lib.makeBinPath runtimeInputs;
  mediaDirs = lib.concatStringsSep ":" ([dataDir] ++ webviewExtraMediaDirs);

  screenpipeArgs =
    [
      "${package}/bin/screenpipe"
      "record"
      "--data-dir"
      dataDir
      "--port"
      (toString port)
    ]
    ++ extraArgs;
in {
  home = lib.mkIf enabled {
    home.packages = homePackages;

    systemd.user.services.${serviceName} = {
      Unit = {
        Description = "Screenpipe recorder and local API";
        After = [
          "graphical-session.target"
          "network.target"
        ];
        Wants = ["graphical-session.target"];
        PartOf = ["default.target"];
      };

      Service = {
        ExecStart = lib.escapeShellArgs (["${waylandSessionRunner}/bin/screenpipe-wayland-session"] ++ screenpipeArgs);
        Environment = [
          "PATH=${screenpipePath}"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.services."${serviceName}-webview" = {
      Unit = {
        Description = "Screenpipe local dashboard and authenticated webview";
        After = ["${serviceName}.service"];
        Requires = ["${serviceName}.service"];
        PartOf = ["default.target"];
      };

      Service = {
        ExecStart = "${webviewPackage}/bin/screenpipe-webview";
        Environment = [
          "SCREENPIPE_UPSTREAM=http://127.0.0.1:${toString port}"
          "SCREENPIPE_WEBVIEW_HOST=${webviewHost}"
          "SCREENPIPE_WEBVIEW_PORT=${toString webviewPort}"
          "SCREENPIPE_DATA_DIR=${dataDir}"
          "SCREENPIPE_MEDIA_DIRS=${mediaDirs}"
          "SCREENPIPE_MEDIA_SCAN_LIMIT=${toString webviewMediaScanLimit}"
          "SCREENPIPE_ALLOW_RAW_SQL=${if webviewAllowRawSql then "1" else "0"}"
          "SCREENPIPE_SERVICE_NAME=${serviceName}"
          "SCREENPIPE_WEBVIEW_SERVICE_NAME=${serviceName}-webview"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };

  nixos = lib.mkIf enabled {};
}
