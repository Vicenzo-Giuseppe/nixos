{
  inputs,
  cell,
}: let
  ctx = import (inputs.self + /lib/context.nix);
  pkgs = import inputs.nixpkgs {
    system = ctx.system;
    config = import (inputs.self + /home/nix-config.nix) {
      inherit (inputs) nixpkgs;
    };
    overlays = import (inputs.self + /home/overlays.nix) {inherit inputs;};
  };
  allPackages = import ./. {
    inherit inputs pkgs;
  };
in
  builtins.removeAttrs allPackages ["codeMcps"]
