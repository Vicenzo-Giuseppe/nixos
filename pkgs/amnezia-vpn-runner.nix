{
  lib,
  writeShellApplication,
  amnezia-vpn,
  coreutils,
  zenity,
  libnotify,
  wl-clipboard,
  xclip,
  systemd,
  polkit,
  procps,
}:
writeShellApplication {
  name = "amnezia-vpn";
  runtimeInputs = [
    amnezia-vpn
    coreutils
    zenity
    libnotify
    wl-clipboard
    xclip
    systemd
    polkit
    procps
  ];
  text = ''
        set -euo pipefail

        secret_file="''${AMNEZIA_AWG_CONF:-/run/secrets/ca-awg.conf}"
        runtime_root="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/amnezia-vpn"
        staged_profile="$runtime_root/ca-awg.conf"
        service_name="AmneziaVPN.service"
        service_bin="${amnezia-vpn}/bin/AmneziaVPN-service"
        service_socket="/var/run/amneziavpn/daemon.socket"

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
          systemctl is-active --quiet "$service_name" \
            || pgrep -f '/AmneziaVPN-service( |$)' >/dev/null 2>&1 \
            || [[ -S "$service_socket" ]]
        }

        start_service_fallback() {
          echo "amnezia-vpn: starting root service binary directly for this session..." >&2
          "$pkexec_bin" sh -lc "nohup '$service_bin' >/tmp/amnezia-vpn-service.log 2>&1 &"
        }

        ensure_service() {
          if service_running; then
            return 0
          fi

          echo "amnezia-vpn: $service_name is not running, attempting to start it..." >&2
          pkexec_bin="$(pkexec_cmd || true)"
          if [[ -z "$pkexec_bin" ]]; then
            echo "amnezia-vpn: pkexec is unavailable; start $service_name manually" >&2
            return 1
          fi

          if ! "$pkexec_bin" systemctl start "$service_name"; then
            echo "amnezia-vpn: failed to start $service_name via systemctl, trying direct service launch..." >&2
            if ! start_service_fallback; then
              echo "amnezia-vpn: failed to launch AmneziaVPN root service" >&2
              return 1
            fi
          fi

          for _ in 1 2 3 4 5 6 7 8 9 10; do
            if service_running; then
              return 0
            fi
            sleep 1
          done

          echo "amnezia-vpn: AmneziaVPN root service did not become active" >&2
          return 1
        }

        ensure_service

        if [[ ! -r "$secret_file" ]]; then
          echo "amnezia-vpn: secret profile is not readable at $secret_file" >&2
          echo "amnezia-vpn: run this on the configured host after NixOS activation." >&2
          exit 1
        fi

        mkdir -p "$runtime_root"
        cp "$secret_file" "$staged_profile"
        chmod 600 "$staged_profile"

        copied_to_clipboard=0
        if [[ $# -eq 0 ]]; then
          if [[ -n "''${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null 2>&1; then
            wl-copy < "$staged_profile" && copied_to_clipboard=1 || true
          elif [[ -n "''${DISPLAY:-}" ]] && command -v xclip >/dev/null 2>&1; then
            xclip -selection clipboard < "$staged_profile" && copied_to_clipboard=1 || true
          fi
        fi

        cat >&2 <<EOF
    AmneziaVPN GUI starting.
    Staged profile: $staged_profile
    If the profile is not already imported, use the GUI import flow and select that file.
    Clipboard loaded: $copied_to_clipboard
    EOF

        if [[ $# -eq 0 ]]; then
          message="AmneziaVPN profile ready for import.

    Profile path:
    $staged_profile

    Clipboard loaded:
    $copied_to_clipboard

    Open the import flow in the GUI and select this file if the profile is not already present.
    If clipboard loaded is 1, you can also paste the profile text in the text import flow."

          if [[ -n "''${DISPLAY:-}" || -n "''${WAYLAND_DISPLAY:-}" ]]; then
            if command -v zenity >/dev/null 2>&1; then
              zenity --info \
                --title="AmneziaVPN" \
                --width=520 \
                --text="$message" \
                >/dev/null 2>&1 &
            elif command -v notify-send >/dev/null 2>&1; then
              notify-send "AmneziaVPN" "$message" >/dev/null 2>&1 || true
            fi
          fi
        fi

        exec AmneziaVPN "$@"
  '';

  meta = {
    description = "Launch AmneziaVPN GUI with the staged SOPS-managed profile";
    mainProgram = "amnezia-vpn";
    platforms = lib.platforms.linux;
  };
}
