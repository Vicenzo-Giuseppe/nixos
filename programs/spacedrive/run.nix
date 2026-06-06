{
  pkgs,
  packageConfig,
  name,
  executable,
  ...
}: let
  packageName = name;
  inherit (packageConfig) package;
in
  pkgs.writeShellApplication {
    name = packageName;
    runtimeInputs = [package];
    text = ''
      exec ${package}/bin/${executable} "$@"
    '';
  }
