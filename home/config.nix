{
  default = import ./default.nix;
  formatters = import ./formatters.nix;
  "nix-config" = import ./nix-config.nix;
  overlays = import ./overlays.nix;
  profile = import ./profile.nix;
}
