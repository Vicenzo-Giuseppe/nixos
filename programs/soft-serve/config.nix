{
  host,
  user,
  ...
}: {
  output = {
    alias = "vault7";
    displayName = "Vault7";
    sshHost = "localhost";
    sshPort = 23231;
    sshUser = "admin";
    publicHost = host;
    httpPort = 23232;
    statsPort = 23233;
    restrictSoftServeToLan = false;
    lanCidrs = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
    localSoftServeUser = user;
  };
}
