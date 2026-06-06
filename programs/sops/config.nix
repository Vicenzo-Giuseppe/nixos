{
  user,
  ...
}: {
  output = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    ageSshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      user_password = {
        neededForUsers = true;
      };
      EXA_API_KEY = {
        owner = user;
      };
      FIRECRAWL_API_KEY = {
        owner = user;
      };
      GITHUB_PERSONAL_ACCESS_TOKEN = {
        owner = user;
      };
      KIMI_CLI_KEY = {
        owner = user;
      };
      aria2 = {
        owner = user;
      };
      vpn_host_ip = {};
    };
    vpnSshConfig = {
      owner = user;
      path = "/run/secrets/vpn_ssh_config";
    };
  };
}
