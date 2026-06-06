{
  inputs,
  cell,
}: {
  config = import ./config.nix;
  home = import ./home.nix;
  nixos = import ./nixos.nix;
  packages = import ./packages.nix;
  programs = import ./programs.nix;
}
