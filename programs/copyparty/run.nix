{
  pkgs,
  packageConfig,
  ...
}: let
  inherit (packageConfig) openScript;
in
  pkgs.writeShellApplication {
    name = "copyparty";
    runtimeInputs = [openScript];
    text = ''
      exec ${openScript}/bin/copyparty-phone-open "$@"
    '';
  }
