{
  pkgs,
  lib,
  packageConfig,
  profileName ? "vicenzo",
  policies ? {},
  enabled,
  ...
}: let
  inherit (packageConfig) basePackage;
  package = pkgs.wrapFirefox basePackage {
    extraPolicies = policies;
  };
in {
  home = lib.mkIf enabled {
    programs.firefox = {
      enable = true;
      inherit package;
      profiles.${profileName} = {
        isDefault = true;
      };
    };
  };

  nixos = lib.mkIf enabled {};
}
