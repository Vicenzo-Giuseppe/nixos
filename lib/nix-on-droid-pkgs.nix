{
  inputs,
  system,
}: let
  root = inputs.self;
  channelsConfig = import (root + /home/nix-config.nix) {
    nixpkgs = inputs.nixpkgs2405;
  };
  sharedOverlays = import (root + /home/overlays.nix) {inherit inputs;};
in
  import inputs.nixpkgs2405 {
    inherit system;
    config = channelsConfig;
    overlays = sharedOverlays;
  }
