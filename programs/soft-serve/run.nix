{
  pkgs,
  packageConfig,
  alias,
  sshHost,
  sshPort,
  sshUser,
  ...
}: let
  inherit (packageConfig) runtimeInputs;
in
  pkgs.writeShellApplication {
    name = alias;
    inherit runtimeInputs;
    text = ''
      exec ${pkgs.openssh}/bin/ssh -p ${toString sshPort} ${sshUser}@${sshHost} "$@"
    '';
  }
