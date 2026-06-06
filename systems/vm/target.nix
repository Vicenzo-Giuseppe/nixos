{inputs, ...}: let
  root = inputs.self;
  ctx = import (root + /lib/context.nix);
  channelsConfig = import (root + /home/nix-config.nix) {
    inherit (inputs) nixpkgs;
  };
  sharedOverlays = import (root + /home/overlays.nix) {inherit inputs;};
in {
  name = "vm";
  kind = "nixos";
  configuration = inputs.nixpkgs.lib.nixosSystem {
    system = ctx.system;
    pkgs = import inputs.nixpkgs {
      system = ctx.system;
      config = channelsConfig;
      overlays = sharedOverlays;
    };
    modules = [./config.nix];
    specialArgs = {
      inherit inputs;
    };
  };
}
