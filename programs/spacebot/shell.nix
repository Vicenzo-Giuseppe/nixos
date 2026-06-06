{
  mkShell,
  packageConfig,
  signalBridge,
  env,
  commands,
  signalEndpoint,
  ...
}: let
  inherit (packageConfig) runtimeInputs;
  inherit (signalBridge) account;
in
  mkShell {
    name = "spacebot";
    packages = runtimeInputs;
    inherit env commands;

    motd = ''
      Spacebot environment
      signal bridge: ${signalEndpoint}
      account: ${account}
    '';
  }
