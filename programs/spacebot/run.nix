{
  pkgs,
  lib,
  packageConfig,
  name,
  executable,
  defaultArgs,
  signalBridge,
  signalEndpoint,
  ...
}: let
  inherit (packageConfig) package runtimeInputs;
  inherit (signalBridge)
    account
    bind
    port
    extraArgs
    ;
in
  pkgs.writeShellApplication {
    inherit name runtimeInputs;
    text = ''
      set -euo pipefail

      SIGNAL_LOG="/tmp/spacebot-signal-cli.log"
      SIGNAL_PID=""

      cleanup() {
        if [ -n "$SIGNAL_PID" ]; then
          kill "$SIGNAL_PID" 2>/dev/null || true
        fi
      }

      trap cleanup EXIT INT TERM

      ${pkgs.lib.getExe pkgs.signal-cli} \
        -a ${account} \
        daemon \
        --http ${bind}:${toString port} \
        ${lib.escapeShellArgs extraArgs} \
        >> "$SIGNAL_LOG" 2>&1 &
      SIGNAL_PID=$!

      for _ in $(seq 1 30); do
        if curl -fsS ${signalEndpoint}/v1/about >/dev/null 2>&1; then
          break
        fi
        sleep 1
      done

      exec ${package}/bin/${executable} ${lib.escapeShellArgs defaultArgs} "$@"
    '';
  }
