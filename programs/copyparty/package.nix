{
  pkgs,
  lib,
  inputs,
  system,
  host,
  user,
  ...
}: let
  unstablePkgs = import inputs.nixpkgs {
    inherit system;
    config = {};
    overlays = [];
  };
  package = pkgs.copyparty or unstablePkgs.copyparty;
  isPhone = host == "phone";
  homeDir =
    if isPhone
    then "/data/data/com.termux.nix/files/home"
    else "/home/${user}";
  port = 3923;
  bind = "0.0.0.0";
  defaultPhoneUrl = "http://phone:3923";
  serverName = if isPhone then "poco-x6-pro" else "phone-videos";
  sharePath = "${homeDir}/storage/shared/Download/zus";
  configHome = "${homeDir}/.config/copyparty";
  dataHome = "${homeDir}/.local/share/copyparty";
  urlFile = "${configHome}/phone-url";
  logFile = "${dataHome}/server.log";
  pidFile = "${dataHome}/server.pid";

  resolveUrlScript = pkgs.writeShellApplication {
    name = "copyparty-phone-url";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      set -euo pipefail

      cfg_dir="${configHome}"
      url_file="${urlFile}"
      default_url="${defaultPhoneUrl}"

      if [ "$#" -gt 0 ]; then
        target="$1"
        case "$target" in
          http://*|https://*)
            printf '%s\n' "$target"
            exit 0
            ;;
          /*)
            printf '%s%s\n' "''${default_url%/}" "$target"
            exit 0
            ;;
          *:*)
            printf 'http://%s\n' "$target"
            exit 0
            ;;
          *)
            printf 'http://%s:${toString port}\n' "$target"
            exit 0
            ;;
        esac
      fi

      if [ -f "$url_file" ]; then
        cat "$url_file"
        exit 0
      fi

      printf '%s\n' "$default_url"
    '';
  };

  setUrlScript = pkgs.writeShellApplication {
    name = "copyparty-phone-set-url";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      set -euo pipefail

      if [ "$#" -ne 1 ]; then
        echo "usage: copyparty-phone-set-url <url|host|host:port>" >&2
        exit 1
      fi

      cfg_dir="${configHome}"
      mkdir -p "$cfg_dir"
      ${resolveUrlScript}/bin/copyparty-phone-url "$1" > "$cfg_dir/phone-url"
      printf 'saved %s\n' "$(cat "$cfg_dir/phone-url")"
    '';
  };

  openScript = pkgs.writeShellApplication {
    name = "copyparty-phone-open";
    runtimeInputs = [pkgs.xdg-utils];
    text = ''
      set -euo pipefail

      base_url="$(${resolveUrlScript}/bin/copyparty-phone-url)"

      if [ "$#" -gt 0 ]; then
        case "$1" in
          http://*|https://*)
            target="$1"
            ;;
          /*)
            target="''${base_url%/}$1"
            ;;
          *)
            target="''${base_url%/}/$1"
            ;;
        esac
      else
        target="$base_url"
      fi

      exec ${pkgs.xdg-utils}/bin/xdg-open "$target"
    '';
  };

  startScript = pkgs.writeShellApplication {
    name = "copyparty-phone-start";
    runtimeInputs = [package pkgs.coreutils];
    text = ''
      set -euo pipefail

      share_dir="''${COPYPARTY_SHARE_DIR:-${sharePath}}"
      bind_addr="''${COPYPARTY_BIND:-${bind}}"
      port_num="''${COPYPARTY_PORT:-${toString port}}"
      state_dir="''${COPYPARTY_STATE_DIR:-${dataHome}}"

      mkdir -p "$state_dir"

      if [ ! -d "$share_dir" ]; then
        echo "copyparty: missing share directory: $share_dir" >&2
        echo "run termux-setup-storage and make sure Download/zus exists" >&2
        exit 1
      fi

      exec ${package}/bin/copyparty \
        -p "$port_num" \
        -i "$bind_addr" \
        --http-only \
        --no-crt \
        --ipa lan \
        --name "${serverName}" \
        -v "$share_dir::r"
    '';
  };

  statusScript = pkgs.writeShellApplication {
    name = "copyparty-phone-status";
    runtimeInputs = [pkgs.coreutils pkgs.gawk pkgs.iproute2 package];
    text = ''
      set -euo pipefail

      pid_file="${pidFile}"
      port_num="''${COPYPARTY_PORT:-${toString port}}"

      if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        printf 'copyparty running with pid %s\n' "$(cat "$pid_file")"
      else
        echo "copyparty not running"
      fi

      ${pkgs.iproute2}/bin/ip -o -4 addr show up scope global \
        | ${pkgs.gawk}/bin/awk '{print $4}' \
        | cut -d/ -f1 \
        | while read -r ip; do
            [ -n "$ip" ] && printf 'http://%s:%s\n' "$ip" "$port_num"
          done
    '';
  };

  startBgScript = pkgs.writeShellApplication {
    name = "copyparty-phone-start-bg";
    runtimeInputs = [pkgs.coreutils pkgs.procps startScript statusScript];
    text = ''
      set -euo pipefail

      state_dir="${dataHome}"
      log_file="${logFile}"
      pid_file="${pidFile}"

      mkdir -p "$state_dir"

      if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        echo "copyparty already running with pid $(cat "$pid_file")"
        exec ${statusScript}/bin/copyparty-phone-status
      fi

      nohup ${startScript}/bin/copyparty-phone-start > "$log_file" 2>&1 &
      echo $! > "$pid_file"
      sleep 1
      exec ${statusScript}/bin/copyparty-phone-status
    '';
  };

  stopScript = pkgs.writeShellApplication {
    name = "copyparty-phone-stop";
    runtimeInputs = [pkgs.coreutils pkgs.procps];
    text = ''
      set -euo pipefail

      pid_file="${pidFile}"

      if [ ! -f "$pid_file" ]; then
        echo "copyparty not running"
        exit 0
      fi

      pid="$(cat "$pid_file")"

      if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        echo "stopped copyparty pid $pid"
      else
        echo "stale pid file for $pid"
      fi

      rm -f "$pid_file"
    '';
  };

  phonePackages = [
    startScript
    startBgScript
    statusScript
    stopScript
  ];

  notebookPackages = [
    resolveUrlScript
    setUrlScript
    openScript
  ];
in {
  inherit package isPhone openScript resolveUrlScript setUrlScript startScript startBgScript statusScript stopScript;
  homePackages = lib.optionals isPhone phonePackages ++ lib.optionals (!isPhone) notebookPackages;
}
