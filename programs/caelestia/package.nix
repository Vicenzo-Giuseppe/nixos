{
  inputs,
  pkgs,
  system,
  ...
}: {
  package = inputs.caelestia-src.packages.${system}.with-cli;
  homePackages = with pkgs; [
    gpu-screen-recorder
  ];
}
