{
  lib,
  enabled,
  inputs,
  pkgs,
  ...
}: let
in {
  home =
    lib.mkIf enabled {
    };
  nixos = lib.mkIf enabled {
    programs.steam = {
      extraCompatPackages = [pkgs.proton-ge-bin];
      protontricks.enable = true;
      enable = true;
    };
  };
}
