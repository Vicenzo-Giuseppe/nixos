{
  lib,
  enabled,
  ...
}: {
  home =
    lib.mkIf enabled {
    };
  nixos = lib.mkIf enabled {
    services.openssh = {
      enable = true;
      settings = {
        AllowUsers = ["vicenzo"];
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
