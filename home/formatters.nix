{
  pkgs,
  inputs,
  ...
}: let
  inherit (inputs) treefmt;
in
  treefmt.lib.evalModule pkgs {
    projectRootFile = "flake.nix";
    programs = {
      alejandra.enable = true;
      mdformat.enable = true;
      stylua.enable = true;
      taplo.enable = true;
    };
  }
