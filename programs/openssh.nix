{
  lib,
  user,
  enabled,
  ...
}: {
  home = lib.mkIf enabled {
    programs.ssh = {
      enable = true;
      includes = ["/run/secrets/vpn_ssh_config"];
      matchBlocks = {
        "*" = {
          identityFile = "/home/${user}/.ssh/id_ed25519";
          identitiesOnly = true;
          extraOptions = {
            AddKeysToAgent = "yes";
            ServerAliveInterval = "30";
            ServerAliveCountMax = "3";
            StrictHostKeyChecking = "accept-new";
            UpdateHostKeys = "yes";
          };
        };
      };
    };
  };
  nixos = lib.mkIf enabled {
    services.openssh = {
      enable = true;
      settings = {
        AllowUsers = [user];
        PasswordAuthentication = false;
      };
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };
  };
}
