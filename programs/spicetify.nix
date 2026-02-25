{
  lib,
  enabled,
  inputs,
  pkgs,
  ...
}: let
  spicePkgs = inputs.spicetify.legacyPackages.${pkgs.stdenv.system};
in {
  home =
    lib.mkIf enabled {
    };
  nixos = lib.mkIf enabled {
    programs.spicetify = {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblockify
        hidePodcasts
        shuffle
      ];
      theme = spicePkgs.themes.hazy;
      colorScheme = "Base";
    };
  };
}
