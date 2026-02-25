{
  pkgs,
  lib,
  enabled,
  ...
}: let
  theme = "Catppuccin Mocha";
in {
  home = lib.mkIf enabled {
    sops = {
      defaultSopsFile = ./secrets.yaml; # or wherever your secrets are
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      secrets = {
        user_password = {
        };
        EXA_API_KEY = {
        };
        FIRECRAWL_API_KEY = {
        };
        GITHUB_PERSONAL_ACCESS_TOKEN = {
        };
        KIMI_CLI_KEY = {
        };
        aria2 = {
        };
      };
    };
  };
  nixos =
    lib.mkIf enabled {
    };
}
