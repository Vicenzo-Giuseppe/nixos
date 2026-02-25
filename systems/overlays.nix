{
  pkgs,
  inputs,
  ...
}: let
  inherit
    (inputs)
    utils
    bun2nix
    neovim
    ;
in [
  utils.overlay
  bun2nix.overlays.default
  neovim.overlays.default
  (
    final: prev:
      import ../pkgs {
        inherit inputs;
        pkgs = final;
      }
  )
]
