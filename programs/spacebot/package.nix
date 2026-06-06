{
  inputs,
  pkgs,
  system,
  ...
}: let
  package = inputs.spacebot.packages.${system}.default;
in {
  inherit package;
  runtimeInputs = [
    package
    pkgs.signal-cli
    pkgs.curl
  ];
}
