{
  rootConfig,
  ...
}: let
  signalBridge = {
    account = "+5519986120971";
    bind = "127.0.0.1";
    port = 8686;
    extraArgs = ["--ignore-stories"];
  };
in {
  output = {
    name = "spacebot";
    executable = "spacebot";
    defaultArgs = ["start"];
    service = {
      variant = "full";
      group = "users";
    };
    inherit signalBridge;
    serviceUser =
      if rootConfig == null
      then null
      else rootConfig.user;
    env = [];
    commands = [];
    signalEndpoint = "http://${signalBridge.bind}:${toString signalBridge.port}";
  };
}
