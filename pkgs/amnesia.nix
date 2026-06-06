{
  lib,
  writeShellApplication,
  amnezia-vpn,
  coreutils,
  zenity,
  libnotify,
  wl-clipboard,
  xclip,
  procps,
  polkit,
}:
writeShellApplication {
  name = "amnesia";
  runtimeInputs = [
    amnezia-vpn
    coreutils
    zenity
    libnotify
    wl-clipboard
    xclip
    procps
    polkit
  ];

  text = ''
        set -euo pipefail

        secret_file="''${AMNEZIA_AWG_CONF:-$HOME/.config/vpn/ca-awg.conf}"
        runtime_root="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/amnezia-vpn"
        staged_profile="$runtime_root/ca-awg.conf"
        gui_config_dir="$runtime_root/xdg-config"
        gui_data_dir="$runtime_root/xdg-data"
        gui_cache_dir="$runtime_root/xdg-cache"
        gui_state_backup_dir="$runtime_root/state-backups"
        service_bin="${amnezia-vpn}/bin/AmneziaVPN-service"
        service_socket="/var/run/amneziavpn/daemon.socket"
        service_log="/tmp/amnezia-vpn-service.log"

        pkexec_cmd() {
          if [[ -x /run/wrappers/bin/pkexec ]]; then
            printf '%s\n' /run/wrappers/bin/pkexec
            return 0
          fi

          if command -v pkexec >/dev/null 2>&1; then
            command -v pkexec
            return 0
          fi

          return 1
        }

        service_running() {
          pgrep -f '/AmneziaVPN-service( |$)' >/dev/null 2>&1 || [[ -S "$service_socket" ]]
        }

        gui_running() {
          pidof AmneziaVPN >/dev/null 2>&1 || pgrep -f '(^| )AmneziaVPN($| )' >/dev/null 2>&1
        }

        ensure_service() {
          if service_running; then
            return 0
          fi

          pkexec_bin="$(pkexec_cmd || true)"
          if [[ -z "$pkexec_bin" ]]; then
            echo "amnesia: pkexec is unavailable; cannot start AmneziaVPN-service" >&2
            exit 1
          fi

          echo "amnesia: starting AmneziaVPN-service..." >&2
          "$pkexec_bin" sh -lc "nohup '$service_bin' >'$service_log' 2>&1 &"

          for _ in 1 2 3 4 5 6 7 8 9 10; do
            if service_running; then
              return 0
            fi
            sleep 1
          done

          echo "amnesia: daemon did not become ready" >&2
          [[ -f "$service_log" ]] && tail -n 40 "$service_log" >&2 || true
          exit 1
        }

        if [[ ! -r "$secret_file" ]]; then
          echo "amnesia: profile is not readable at $secret_file" >&2
          echo "amnesia: expected your active local profile there, or set AMNEZIA_AWG_CONF." >&2
          exit 1
        fi

        ensure_service

        mkdir -p "$runtime_root"
        cp "$secret_file" "$staged_profile"
        chmod 600 "$staged_profile"
        mkdir -p "$gui_config_dir" "$gui_data_dir" "$gui_cache_dir" "$gui_state_backup_dir"

        copied_to_clipboard=0
        if [[ $# -eq 0 ]]; then
          if [[ -n "''${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null 2>&1; then
            wl-copy < "$staged_profile" && copied_to_clipboard=1 || true
          elif [[ -n "''${DISPLAY:-}" ]] && command -v xclip >/dev/null 2>&1; then
            xclip -selection clipboard < "$staged_profile" && copied_to_clipboard=1 || true
          fi
        fi

        cat >&2 <<EOF
    Amnezia GUI starting.
    Staged profile: $staged_profile
    Clipboard loaded: $copied_to_clipboard
    XDG_CONFIG_HOME: $gui_config_dir
    XDG_DATA_HOME: $gui_data_dir
    EOF

        if [[ $# -eq 0 ]]; then
          message="Amnezia GUI profile ready.

    Profile path:
    $staged_profile

    Clipboard loaded:
    $copied_to_clipboard

    This launch uses isolated GUI state so old saved servers do not interfere.
    Import the file in the GUI, or paste the profile text if clipboard loaded is 1."

          if [[ -n "''${DISPLAY:-}" || -n "''${WAYLAND_DISPLAY:-}" ]]; then
            if command -v zenity >/dev/null 2>&1; then
              zenity --info --title="Amnezia" --width=520 --text="$message" >/dev/null 2>&1 &
            elif command -v notify-send >/dev/null 2>&1; then
              notify-send "Amnezia" "$message" >/dev/null 2>&1 || true
            fi
          fi
        fi

        if [[ $# -eq 0 ]] && gui_running; then
          echo "amnesia: restarting existing AmneziaVPN GUI instance..." >&2
          pkill -f '(^| )AmneziaVPN($| )' || true

          for _ in 1 2 3 4 5; do
            if ! gui_running; then
              break
            fi
            sleep 1
          done
        fi

        export XDG_CONFIG_HOME="$gui_config_dir"
        export XDG_DATA_HOME="$gui_data_dir"
        export XDG_CACHE_HOME="$gui_cache_dir"

        exec AmneziaVPN "$@"
  '';

  meta = {
    description = "GUI Amnezia runner using the active local fast VPN profile";
    mainProgram = "amnesia";
    platforms = lib.platforms.linux;
  };
}
