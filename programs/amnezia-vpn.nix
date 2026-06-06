{
  enabled,
  pkgs,
  lib,
  ...
}: {
  home = lib.mkIf enabled {
    home.packages = [
      pkgs.amneziawg-go
      pkgs.amneziawg-tools
    ];
  };

  nixos = {config, ...}: let
    cfg = config.programs.amneziaVpn;
    vpnCheckScript = pkgs.writeShellApplication {
      name = "vpn-check";
      runtimeInputs = with pkgs; [
        coreutils
        curl
        gawk
        gnugrep
        iproute2
        iputils
        jq
        iperf3
        wireguard-tools
      ];
      text = ''
        set -euo pipefail

        iface="''${1:-''${VPN_CHECK_INTERFACE:-${lib.escapeShellArg cfg.checkInterface}}}"
        iperf_server="''${VPN_CHECK_SERVER:-${lib.escapeShellArg cfg.checkIperfServer}}"
        iperf_port="''${VPN_CHECK_PORT:-${toString cfg.checkIperfPort}}"
        expected_country="''${VPN_CHECK_COUNTRY:-${lib.escapeShellArg cfg.checkExpectedCountry}}"
        ping_target="''${VPN_CHECK_PING_TARGET:-${lib.escapeShellArg cfg.checkPingTarget}}"
        test_seconds="''${VPN_CHECK_DURATION:-${toString cfg.checkDurationSeconds}}"

        failures=0

        ok() {
          printf '[OK] %s\n' "$*"
        }

        warn() {
          printf '[WARN] %s\n' "$*"
        }

        fail() {
          printf '[FAIL] %s\n' "$*"
          failures=1
        }

        printf 'vpn-check\n'
        printf '  interface: %s\n' "$iface"
        printf '  iperf endpoint: %s:%s\n' "$iperf_server" "$iperf_port"

        if ! ip link show dev "$iface" >/dev/null 2>&1; then
          fail "interface '$iface' is missing/down"
          exit 1
        fi
        ok "interface '$iface' is up"

        wg_dump="$(wg show "$iface" 2>/dev/null || true)"
        if [[ -n "$wg_dump" ]]; then
          hs_line="$(printf '%s\n' "$wg_dump" | awk '/latest handshake/ {sub(/^[[:space:]]+/, ""); print; exit}')"
          xfer_line="$(printf '%s\n' "$wg_dump" | awk '/transfer/ {sub(/^[[:space:]]+/, ""); print; exit}')"
          if [[ -n "$hs_line" ]]; then
            ok "$hs_line"
          else
            warn "no handshake line found"
          fi
          if [[ -n "$xfer_line" ]]; then
            ok "$xfer_line"
          else
            warn "no transfer line found"
          fi
        else
          warn "unable to read wireguard state for '$iface'"
        fi

        route_line="$(ip route get "$ping_target" 2>/dev/null | head -n1 || true)"
        if [[ -n "$route_line" ]]; then
          if [[ "$route_line" == *" dev $iface "* ]]; then
            ok "route to $ping_target uses '$iface'"
          else
            warn "route to $ping_target is '$route_line'"
          fi
        else
          warn "could not resolve route to $ping_target"
        fi

        ipinfo_json="$(curl -fsS --max-time 10 https://ipinfo.io/json || true)"
        if [[ -n "$ipinfo_json" ]]; then
          public_ip="$(printf '%s' "$ipinfo_json" | jq -r '.ip // empty')"
          public_country="$(printf '%s' "$ipinfo_json" | jq -r '.country // empty')"
          if [[ -n "$public_ip" ]]; then
            ok "public IP: $public_ip"
          else
            warn "unable to parse public IP"
          fi
          if [[ "$public_country" == "$expected_country" ]]; then
            ok "exit country: $public_country"
          else
            warn "exit country '$public_country' (expected '$expected_country')"
          fi
        else
          warn "ipinfo lookup failed"
        fi

        ping_out="$(ping -c 5 -n -w 12 "$ping_target" 2>/dev/null || true)"
        if [[ -n "$ping_out" ]]; then
          loss_pct="$(printf '%s\n' "$ping_out" | awk -F', ' '/packet loss/ {gsub("%", "", $3); print $3}' | awk '{print $1}')"
          rtt_line="$(printf '%s\n' "$ping_out" | awk -F' = ' '/^rtt / {print $2}')"
          if [[ -n "$loss_pct" ]]; then
            ok "ping loss: ''${loss_pct}%"
          else
            warn "could not parse ping loss"
          fi
          if [[ -n "$rtt_line" ]]; then
            ok "ping rtt min/avg/max/mdev: $rtt_line"
          else
            warn "could not parse ping RTT"
          fi
        else
          warn "ping test failed"
        fi

        up_json="$(iperf3 -c "$iperf_server" -p "$iperf_port" -t "$test_seconds" --json 2>/dev/null || true)"
        if [[ -n "$up_json" ]]; then
          up_mbps="$(printf '%s' "$up_json" | jq -r '(.end.sum_sent.bits_per_second / 1000000) | floor')"
          if [[ "$up_mbps" != "null" ]]; then
            ok "upload throughput: ''${up_mbps} Mbps"
          else
            warn "could not parse upload throughput"
          fi
        else
          fail "upload throughput test failed"
        fi

        down_json="$(iperf3 -c "$iperf_server" -p "$iperf_port" -t "$test_seconds" -R --json 2>/dev/null || true)"
        if [[ -n "$down_json" ]]; then
          down_mbps="$(printf '%s' "$down_json" | jq -r '(.end.sum_received.bits_per_second / 1000000) | floor')"
          if [[ "$down_mbps" != "null" ]]; then
            ok "download throughput: ''${down_mbps} Mbps"
          else
            warn "could not parse download throughput"
          fi
        else
          fail "download throughput test failed"
        fi

        if [[ "$failures" -eq 0 ]]; then
          ok "vpn-check finished"
        else
          fail "vpn-check finished with failures"
        fi

        exit "$failures"
      '';
    };
    peer =
      {
        publicKey = cfg.publicKey;
        allowedIPs = cfg.allowedIPs;
        endpoint = cfg.endpoint;
        persistentKeepalive = cfg.persistentKeepalive;
      }
      // lib.optionalAttrs (cfg.presharedKeyFile != null) {
        presharedKeyFile = cfg.presharedKeyFile;
      };
    interfaceConfig =
      {
        autostart = true;
        address = cfg.addresses;
        privateKeyFile = cfg.privateKeyFile;
        dns = cfg.dns;
        peers = [peer];
      }
      // lib.optionalAttrs (cfg.listenPort != null) {
        listenPort = cfg.listenPort;
      };
  in {
    options.programs.amneziaVpn = {
      enableAutoconnect = lib.mkEnableOption "boot-time WireGuard connection, including exported Amnezia WireGuard profiles";

      interface = lib.mkOption {
        type = lib.types.str;
        default = "amnezia";
        description = "WireGuard interface name used for the VPN profile.";
      };

      addresses = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["10.8.0.2/32"];
        description = "Local addresses from the VPN profile.";
      };

      dns = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["1.1.1.1" "1.0.0.1"];
        description = "DNS servers to apply while the VPN interface is active.";
      };

      privateKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "/run/secrets/amnezia-wg-private-key";
        description = "Absolute path to the private key file for the VPN profile. Keep this outside the Nix store.";
      };

      listenPort = lib.mkOption {
        type = lib.types.nullOr lib.types.port;
        default = null;
        description = "Optional local listen port from the exported profile.";
      };

      publicKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Peer public key from the VPN profile.";
      };

      presharedKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "/run/secrets/amnezia-wg-preshared-key";
        description = "Absolute path to the optional preshared key file. Keep this outside the Nix store.";
      };

      endpoint = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "203.0.113.10:51820";
        description = "Peer endpoint from the VPN profile.";
      };

      allowedIPs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "0.0.0.0/0"
          "::/0"
        ];
        description = "Allowed IPs routed through the VPN peer.";
      };

      persistentKeepalive = lib.mkOption {
        type = lib.types.int;
        default = 25;
        description = "Persistent keepalive value for the VPN peer.";
      };

      checkInterface = lib.mkOption {
        type = lib.types.str;
        default = "ca-awg";
        description = "Interface checked by the vpn-check command by default.";
      };

      checkIperfServer = lib.mkOption {
        type = lib.types.str;
        default = "10.44.0.1";
        description = "WireGuard-side iperf endpoint used by vpn-check.";
      };

      checkIperfPort = lib.mkOption {
        type = lib.types.port;
        default = 5201;
        description = "iperf TCP port used by vpn-check.";
      };

      checkExpectedCountry = lib.mkOption {
        type = lib.types.str;
        default = "CA";
        description = "Expected country code for external IP checks in vpn-check.";
      };

      checkPingTarget = lib.mkOption {
        type = lib.types.str;
        default = "1.1.1.1";
        description = "Ping target used by vpn-check latency checks.";
      };

      checkDurationSeconds = lib.mkOption {
        type = lib.types.ints.positive;
        default = 6;
        description = "Duration in seconds for each iperf run in vpn-check.";
      };
    };

    config = lib.mkIf enabled {
      security.polkit.enable = true;

      environment.systemPackages = [vpnCheckScript];

      boot.extraModulePackages = [config.boot.kernelPackages.amneziawg];
      boot.kernelModules = ["amneziawg"];

      assertions = lib.optionals cfg.enableAutoconnect [
        {
          assertion = cfg.addresses != [];
          message = "programs.amneziaVpn.addresses must be set when autoconnect is enabled.";
        }
        {
          assertion = cfg.privateKeyFile != null;
          message = "programs.amneziaVpn.privateKeyFile must be set when autoconnect is enabled.";
        }
        {
          assertion = cfg.publicKey != null;
          message = "programs.amneziaVpn.publicKey must be set when autoconnect is enabled.";
        }
        {
          assertion = cfg.endpoint != null;
          message = "programs.amneziaVpn.endpoint must be set when autoconnect is enabled.";
        }
      ];

      networking.wg-quick.interfaces = lib.mkIf cfg.enableAutoconnect {
        ${cfg.interface} = interfaceConfig;
      };
    };
  };
}
