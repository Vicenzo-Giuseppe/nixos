{
  inputs,
  pkgs,
  system,
  ...
}: {
  package = inputs.spacedrive.packages.${system}.default;
  homePackages = with pkgs; [
    seahorse
  ];
}
