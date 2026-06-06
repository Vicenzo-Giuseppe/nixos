{
  lib,
  enabled,
  defaultSopsFile ? ./secrets.yaml,
  defaultSopsFormat ? "yaml",
  ageSshKeyPaths ? ["/etc/ssh/ssh_host_ed25519_key"],
  secrets ? {},
  vpnSshConfig ? {
    path = "/run/secrets/vpn_ssh_config";
  },
  ...
}: {
  # User-facing programs read system-managed secret files, so the host SSH key
  # is enough after a clone on this machine.
  home = lib.mkIf enabled {};

  nixos = {config, ...}:
    lib.mkIf enabled {
      sops = {
        inherit defaultSopsFile defaultSopsFormat secrets;
        age.sshKeyPaths = ageSshKeyPaths;
        templates.vpn_ssh_config = vpnSshConfig // {
          content = ''
            Host ca-vpn
              HostName ${config.sops.placeholder.vpn_host_ip}
              User root

            Host vpn-toronto
              HostName ${config.sops.placeholder.vpn_host_ip}
              User root
          '';
        };
      };
    };
}
