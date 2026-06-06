#!/usr/bin/env bash
set -u

cd "$HOME/nixos" || exit

echo "running nix-on-droid switch from: $(pwd)"
date || true
echo "stopping stale nix-daemon processes if any"
ps -ef 2>/dev/null | awk '/nix-daemon/ && !/awk/ { print $2 }' | xargs -r kill 2>/dev/null || true
sleep 1
nix-on-droid switch --flake .#phone --show-trace -L
status=$?
echo "nix-on-droid switch exit status: $status"
date || true
exit "$status"
