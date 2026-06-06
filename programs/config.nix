{
  inputs,
  cell,
}: let
  loader = import (inputs.self + /lib/cell-loader.nix) {
    inherit inputs cell;
    baseDir = ./.;
  };
in
  loader.config
