{
  lib,
  enabled,
  pkgs,
  ...
}:
let
in
{
  home = lib.mkIf enabled {
    home.packages = with pkgs; [ spacedrive ];
  };
  nixos = lib.mkIf enabled {
  };
}
