{
  lib,
  pkgs,
  enabled,
  ...
}: let
  # Self-signed TLS cert generated at build time — local use only.
  # The key lives in the Nix store (world-readable), which is fine for a
  # local bot inbox. When you get a real domain, swap to x509.useACMEHost.
  localCert =
    pkgs.runCommand "mailserver-local-cert" {
      nativeBuildInputs = [pkgs.openssl];
    } ''
      mkdir -p $out
      openssl req -x509 -newkey rsa:4096 \
        -keyout $out/key.pem \
        -out    $out/cert.pem \
        -days 3650 -nodes \
        -subj "/CN=localhost" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
    '';
in {
  home = lib.mkIf enabled {};

  nixos = lib.mkIf enabled {
    # Trust the self-signed cert system-wide so Spacebot accepts it.
    security.pki.certificateFiles = ["${localCert}/cert.pem"];

    # ── Mail server (local-only) ─────────────────────────────────────────
    mailserver = {
      enable = true;
      stateVersion = 3;

      # Pin to flake input — skip nixpkgs release mismatch warning.
      enableNixpkgsReleaseCheck = false;

      fqdn = "localhost";
      domains = ["localhost"];

      # Bot account used by Spacebot.
      # NOTE: migrate to sops hashedPasswordFile once you have your age key.
      loginAccounts."bot@localhost" = {
        hashedPassword = "$6$dMTAymLp30m.9BOJ$ToSfPsFZAYqIP1lYKYhY.mSeS8t2m32hmDlDc.WH94z5hCX6PZCZ3GRwIY2OfbpD9K7XFbL3GO5ys.WxAgcjN0";
      };

      # Self-signed cert — no ACME or nginx needed.
      x509.certificateFile = "${localCert}/cert.pem";
      x509.privateKeyFile = "${localCert}/key.pem";

      localDnsResolver = false;

      enableImap = false; # no plain IMAP/143
      enableImapSsl = true; # IMAPS/993  ← Spacebot imap_port
      enablePop3 = false;
      enableSubmission = true; # SMTP submission/587 STARTTLS
      enableSubmissionSsl = false; # no SMTPS/465

      virusScanning = false;
      enableManageSieve = false;
    };
  };
}
